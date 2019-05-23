Shader "Unlit/Particles"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "common.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 quantity : TEXCOORD1;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			#define TAU 6.28
			
			v2f vert (appdata v)
			{
				v2f o;

				// quad index
				float id = v.quantity.x;

				// world space
				o.vertex = mul(UNITY_MATRIX_M, v.vertex);

				// distribute on a circle
				float a = id * TAU;
				o.vertex.xz = float2(cos(a),sin(a));

				// distribute random on a plane
				o.vertex.x = rand(v.vertex.xy) * 2. - 1.;
				o.vertex.z = rand(v.vertex.xz) * 2. - 1.;

				float _Range = 5.0;
				o.vertex.xz *= _Range;

				// fall
				float _Speed = 0.01;
				float _Height = 10.;
				o.vertex.y = (1.0-fmod(_Time.y*_Speed + v.vertex.y, 1.0)) * _Height;

				//rotation2D(o.vertex.xz, _Time.y * v.vertex.y * 0.01);

				// stretch quad (billboard)
				float _Radius = 0.05;
				o.vertex.xy += v.uv.xy * _Radius;
				//o.vertex.y += v.uv.y * 4. * _Radius;

				o.color = float4(rand(v.quantity), rand(v.quantity+float2(15.4,5)), rand(v.quantity+float2(95,5)), 1);

				o.vertex = mul(UNITY_MATRIX_VP, o.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv = i.uv;
				uv.y -= sqrt(abs(uv.x)*4.)*.25-.2;
				if (length(uv) > 1.) discard;
				// sample the texture
				fixed4 col = i.color;
				return col;
			}
			ENDCG
		}
	}
}

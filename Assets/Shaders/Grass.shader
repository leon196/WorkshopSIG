Shader "Unlit/Grass"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Radius ("Radius", Float) = 0.1
		_Range ("Range", Float) = 5
		_Height ("Height", Float) = 0.2
		_GrowRangeMin ("_GrowRangeMin", Float) = 2
		_GrowRangeMax ("_GrowRangeMax", Float) = 1
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
			float3 _Target;
			float _Range, _Height, _Radius, _Speed, _GrowRangeMin, _GrowRangeMax;

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
				o.vertex.y = 0;

				o.vertex.xz *= _Range;

				float y = v.uv.y * 0.5 + 0.5;

				float grow = smoothstep(_GrowRangeMin, _GrowRangeMax, length(o.vertex.xyz-_Target));

				a = TAU * noiseIQ(o.vertex.xyz * 4.);
				o.vertex.xz += float2(cos(a),sin(a)) * y * .2 * grow;

				// stretch quad (billboard)
				float3 forward = normalize(_WorldSpaceCameraPos - o.vertex.xyz);
				float3 right = normalize(cross(float3(0,1,0), forward));
				//float3 up = normalize(cross(forward, right));
				float3 up = float3(0,1,0);

				o.vertex.xyz += right * v.uv.x * _Radius * (1.0-y) * grow;
				o.vertex.xyz += up * y * _Height * grow;

				o.color = float4(0,y,0,1);

				o.vertex = mul(UNITY_MATRIX_VP, o.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv = i.uv;
				fixed4 col = i.color;
				return col;
			}
			ENDCG
		}
	}
}

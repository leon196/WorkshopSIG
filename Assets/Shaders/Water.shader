Shader "Unlit/Water"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_ColorA ("Color", Color) = (1,1,1,1)
		_ColorB ("Color", Color) = (0,0,1,1)
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

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float wave : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST, _ColorA, _ColorB;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_M, v.vertex);

				float2 uv = v.uv;
				uv.x += _Time.y * 0.05;
				float wave = tex2Dlod(_MainTex, float4(uv, 0, 0)).r;

				uv = v.uv;
				uv.xy += _Time.y * 0.05;
				wave *= tex2Dlod(_MainTex, float4(uv, 0, 0)).r;

				// wave = sqrt(wave);
				wave = abs(sin(wave*3.1415));

				float3 pos = o.vertex.xyz * 2.;
				wave *= .5+.5*min(1., 1.-abs(sin(pos.x*.5-_Time.y+sin(pos.z*.2+_Time.y))) 
					+ 1.-abs(sin(pos.z*.5-_Time.y*2.+sin(pos.x*.5+_Time.y)*.5)));

				// extrude
				o.vertex.y += wave * 0.2;
				o.wave = wave;
				o.vertex = mul(UNITY_MATRIX_VP, o.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = lerp(_ColorA, _ColorB, i.wave);

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}

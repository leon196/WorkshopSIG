Shader "Leon/Filter" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_Range ("Range", Range(0,1)) = 0
		_Count ("God's ray Count", Float) = 20
		_Treshold ("God's ray Treshold", Range(0,1)) = 0.5
		_Strength ("God's ray Strength", Float) = 0.99
	}
	SubShader {
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass {
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			float _Range, _Strength, _Count, _Treshold;

			fixed4 frag (v2f_img i) : SV_Target {

				// pixelate
				float2 lod = _ScreenParams.xy/lerp(10, 100, _Range);
				float2 uv = i.uv;
				//uv = floor(uv * lod) / lod;

				fixed4 col = tex2D(_MainTex, uv);

				float2 p = uv;

				for (float index = _Count; index > 0; --index) {
					// center uv
					p = p * 2. - 1.;
					// fix aspect ratio
					p.x *= _ScreenParams.x / _ScreenParams.y;
					// scale
					p *= _Strength;
					// back to normal uv
					p.x *= _ScreenParams.y / _ScreenParams.x;
					p = p * 0.5 + 0.5;

					float4 color = tex2D(_MainTex, p);
					col += step(_Treshold, color) * color / _Count;
				}

				return col;
			}
			ENDCG
		}
	}
}

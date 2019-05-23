Shader "Leon/Filter" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_Range ("Range", Range(0,1)) = 0
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
			float _Range;

			fixed4 frag (v2f_img i) : SV_Target {

				// pixelate
				float2 lod = _ScreenParams.xy/lerp(10, 100, _Range);
				float2 uv = i.uv;
				//uv = floor(uv * lod) / lod;
				
				fixed4 col = tex2D(_MainTex, uv);

				return col;
			}
			ENDCG
		}
	}
}

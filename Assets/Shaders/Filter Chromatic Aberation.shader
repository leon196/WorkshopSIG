Shader "Leon/Filter Chromatic Aberation" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_Range ("Range", Range(0,1)) = 0
		_Count ("God's ray Count", Float) = 20
		_Treshold ("God's ray Treshold", Range(0,1)) = 0.5
		_ShakeStrength ("Shake Strength", Float) = 0.99
		_AberationStrength ("Aberation Strength", Float) = 0.99
	}
	SubShader {
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass {
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "common.cginc"
			
			sampler2D _MainTex;
			float _Range, _ShakeStrength, _AberationStrength, _Count, _Treshold;

			fixed4 frag (v2f_img i) : SV_Target {

				float2 uv = i.uv;

				float a = TAU * rand(frac(_Time.y));
				uv += _ShakeStrength * float2(cos(a),sin(a)) * 4. / _ScreenParams.y; 

				// uv.y += sin(uv.x * 20. + sin(uv.x * 100.)) * .1;

				float unit = _AberationStrength * 20.0 / _ScreenParams.y;
				float2 pos = uv * 2. - 1.;
				unit *= length(pos);

				float red = tex2D(_MainTex, uv + float2(unit, 0)).r;
				float green = tex2D(_MainTex, uv + float2(-unit, 0)).g;
				float blue = tex2D(_MainTex, uv + float2(0, unit)).b;

				fixed4 col = fixed4(red, green, blue, 1);

				return col;
			}
			ENDCG
		}
	}
}

Shader "Hidden/GrassMap"
{
	Properties
	{
		_MainTex ("Main", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex, _GrassMap;

			fixed4 frag (v2f_img i) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, i.uv);
				float2 pos = i.uv - float2(sin(_Time.y)*0.5+0.5, .2);
				float shape = step(length(pos), 0.1);

				color.r *= 0.99;
				color.r += shape;
				color.r = clamp(color.r, 0, 1);
				return color;
			}
			ENDCG
		}
	}
}

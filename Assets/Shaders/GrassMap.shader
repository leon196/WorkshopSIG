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
			float3 _Target;

			fixed4 frag (v2f_img i) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, i.uv);

				float2 target = _Target.xz;
				target = target / 8. + 0.5;

				// float2 pos = i.uv - float2(sin(_Time.y)*0.5+0.5, .2);
				float shape = smoothstep(0.1, 0.0, length(i.uv - target));

				color.r *= 0.99;
				color.r += shape;
				color.r = clamp(color.r, 0, 1);
				return color;
			}
			ENDCG
		}
	}
}

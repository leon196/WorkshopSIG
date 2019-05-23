Shader "Hidden/GrassMap"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
			
			sampler2D _MainTex;

			fixed4 frag (v2f_img i) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, i.uv);
				float2 pos = i.uv - float2(sin(_Time.y)*0.5+0.5, 0);
				color.rgb = float3(1,1,1) * step(0.2, length(pos));
				return color;
			}
			ENDCG
		}
	}
}

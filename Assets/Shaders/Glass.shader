Shader "Unlit/Glass"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Strength ("Strength", Float) = 0.1
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" }
		
		GrabPass { "_BackgroundTexture" }

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
				float4 grabPos : TEXCOORD1;
			};

			sampler2D _MainTex, _BackgroundTexture;
			float4 _MainTex_ST;
			float _Strength;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.grabPos = ComputeGrabScreenPos(o.vertex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				float4 uv = i.grabPos;
				float angle = tex2D(_MainTex, i.uv).r * 3.1415 * 2.;
				uv.xy += float2(cos(angle),sin(angle)) * _Strength;
				fixed4 col = tex2Dproj(_BackgroundTexture, uv);
				return col;
			}
			ENDCG
		}
	}
}

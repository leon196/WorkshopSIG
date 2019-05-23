Shader "Leon/Shader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_Range ("Range", Range(0,1)) = 0
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
			
			#include "UnityCG.cginc"

			struct attribute
			{
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct varying
			{
				float2 uv : TEXCOORD0;
				float3 worldPosition : TEXCOORD1;
				float4 position : SV_POSITION;
			};

			uniform sampler2D _MainTex;
			uniform float4 _Color;
			uniform float _Range;
			
			varying vert (attribute v)
			{
				varying o;
				//o.position = UnityObjectToClipPos(v.position);
				o.position = v.position;
				o.position.y += sin(_Time.y);
				o.worldPosition = o.position.xyz;
				o.position = mul(UNITY_MATRIX_M, o.position);
				o.position = mul(UNITY_MATRIX_V, o.position);
				o.position = mul(UNITY_MATRIX_P, o.position);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (varying i) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, i.uv);
				color *= sin(i.worldPosition.y * 10. + _Time.y)*0.5+0.5;
				//color *= _Color;

				color.r = sin(_Time.y)*0.5+0.5;
				color.b = _Range;
				return color;
			}
			ENDCG
		}
	}
}

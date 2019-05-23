Shader "Leon/Dissolve"
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
			uniform float _Range, _Dissolve;
			
			varying vert (attribute v)
			{
				varying o;
				o.position = v.position;
				o.worldPosition = o.position.xyz;
				o.position.xyz *= 1.0 + _Dissolve;
				o.position = mul(UNITY_MATRIX_M, o.position);
				o.position = mul(UNITY_MATRIX_V, o.position);
				o.position = mul(UNITY_MATRIX_P, o.position);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (varying i) : SV_Target
			{
				fixed4 color = _Color;
				float blend = _Dissolve;
				float gray = tex2D(_MainTex, i.uv).r;
				color.r += 1.-abs(blend-gray);
				if (gray < blend) discard;
				return color;
			}
			ENDCG
		}
	}
}

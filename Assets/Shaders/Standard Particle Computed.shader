
Shader "Leon/Standard Particle Computed"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard vertex:vert addshadow
        #pragma target 5.0
        #include "common.cginc"

        sampler2D _MainTex;

        struct Input
        {
            float2 anchor;
            float4 color;
            float3 normal;
        };

        half _Glossiness, _Metallic, _Emission;
        float _Radius;
        fixed4 _Color;

        #ifdef SHADER_API_D3D11
        struct PointData { float3 position, velocity, seed; };
        StructuredBuffer<PointData> _Particles;

        #endif

        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            
            #ifdef SHADER_API_D3D11
            // sample position
            v.vertex = float4(_Particles[v.texcoord1.y].position, 1.0);
            #endif
            
            // strecth (billboard)
            v.vertex = mul(UNITY_MATRIX_M, v.vertex);
			float3 forward = normalize(_WorldSpaceCameraPos - v.vertex.xyz);
			float3 right = normalize(cross(float3(0,1,0), forward));
			float3 up = normalize(cross(forward, right));
            v.vertex.xyz += right * v.texcoord.x * _Radius;
            v.vertex.xyz += up * v.texcoord.y * _Radius;
            v.vertex = mul(unity_WorldToObject, v.vertex);
            o.color = _Color;
            o.anchor = v.texcoord.xy;
            o.normal = float3(0,1,0);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            o.Emission = IN.color.rgb;
            o.Metallic = 0;
            o.Smoothness = 0;
            o.Alpha = 1.0;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

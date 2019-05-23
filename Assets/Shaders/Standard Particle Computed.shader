
Shader "Leon/Standard Particle Computed"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Mask ("Mask", 2D) = "white" {}
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

        sampler2D _MainTex, _Mask;

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
        struct ParticleData { float3 position, velocity, seed; };
        StructuredBuffer<ParticleData> _Particles;

        #endif

        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            
			float3 forward = normalize(_WorldSpaceCameraPos - v.vertex.xyz);

            #ifdef SHADER_API_D3D11
            // sample position
            ParticleData particle = _Particles[v.texcoord1.y];
            v.vertex = float4(particle.position, 1.0);
            forward = particle.velocity;
            #endif
            
            // strecth (billboard)
            v.vertex = mul(UNITY_MATRIX_M, v.vertex);
			float3 right = normalize(cross(float3(0,1,0), forward));
			float3 up = normalize(cross(forward, right));
            v.vertex.xyz += right * v.texcoord.x * _Radius;
            v.vertex.xyz += up * v.texcoord.y * _Radius;

            v.vertex.xyz -= normalize(forward) * abs(v.texcoord.x) * _Radius * (sin(_Time.y * 20. + v.texcoord1.y * .15));

            v.vertex = mul(unity_WorldToObject, v.vertex);

            o.color = float4(hsv2rgb(float3(rand(v.texcoord1.xy), 0.9, 0.9)), 1);
            o.anchor = v.texcoord.xy;
            o.normal = forward;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float2 uv = IN.anchor * 0.5 + 0.5;
            if (tex2D(_Mask, uv).r < 0.1) discard;
            o.Albedo = IN.color.rgb;
            o.Metallic = 0;
            o.Smoothness = 0;
            o.Alpha = 1.0;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

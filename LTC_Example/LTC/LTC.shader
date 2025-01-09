Shader "LTC/LTC"
{
    Properties
    {
        _LTC_LUT ("LTC LUT", 2D) = "black" { }
        _Fresnel_LUT ("Fresnel LUT", 2D) = "black" { }

        _BaseColor ("BaseColor", Color) = (1, 1, 1, 1)
        _BaseColorTexture ("BaseColor Texture", 2D) = "white" { }

        _Roughness ("Roughness", Range(0, 1)) = 0.5
        _RoughnessTexture ("Roughness Texture", 2D) = "white" { }

        _Metallic ("Metallic", Range(0, 1)) = 1.0
        _MetallicTexture ("Metallic Texture", 2D) = "white" { }

        _QuadLight_V1 ("Quad Light V1", Vector) = (0, 0, 0, 0)
        _QuadLight_V2 ("Quad Light V2", Vector) = (0, 0, 0, 0)
        _QuadLight_V3 ("Quad Light V3", Vector) = (0, 0, 0, 0)
        _QuadLight_V4 ("Quad Light V4", Vector) = (0, 0, 0, 0)

        [HDR] _AreaLightColor ("Area Light Color", Color) = (1, 1, 1, 1)
        [Toggle] _UseAreaLightTexture ("Use Area Light Texture", Float) = 0
        _AreaLightTexture ("Area Light Texture", 2D) = "white" { }
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _LTC_LUT;
            sampler2D _Fresnel_LUT;

            float3 _QuadLight_V1;
            float3 _QuadLight_V2;
            float3 _QuadLight_V3;
            float3 _QuadLight_V4;

            float3 _BaseColor;
            sampler2D _BaseColorTexture;

            float _Roughness;
            sampler2D _RoughnessTexture;

            float _Metallic;
            sampler2D _MetallicTexture;

            float3 _AreaLightColor;
            float _UseAreaLightTexture;
            sampler2D _AreaLightTexture;
            float4 _AreaLightTexture_ST;

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 texcoord : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal).xyz;
                o.texcoord = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            static const float LUT_SIZE = 64;
            static const float LUT_SCALE = (LUT_SIZE - 1.0) / LUT_SIZE;
            static const float LUT_BIAS = 0.5 / LUT_SIZE;

            float2 GetLUT_Texcoord(float cosine, float roughness)
            {
                float2 uv;
                uv.x = roughness;
                uv.y = sqrt(1.0 - cosine);
                uv = uv * LUT_SCALE + LUT_BIAS;
                return uv;
            }

            float3x3 GetLTC_InverseMatrix(float2 uv, sampler2D lutSampler)
            {
                float4 lut = tex2D(lutSampler, uv);
                return float3x3(
                    float3(lut.x, 0, lut.y),
                    float3(0, 1, 0),
                    float3(lut.z, 0, lut.w)
                );
            }

            // Z-Clip
            void ClipQuadToHorizon(inout float3 L[5], out int n)
            {
                // detect clipping config
                int config = 0;
                if (L[0].z > 0.0) config += 1;
                if (L[1].z > 0.0) config += 2;
                if (L[2].z > 0.0) config += 4;
                if (L[3].z > 0.0) config += 8;

                // clip
                n = 0;

                if (config == 0)
                {
                    // clip all

                }
                else if (config == 1) // V1 clip V2 V3 V4

                {
                    n = 3;
                    L[1] = -L[1].z * L[0] + L[0].z * L[1];
                    L[2] = -L[3].z * L[0] + L[0].z * L[3];
                }
                else if (config == 2) // V2 clip V1 V3 V4

                {
                    n = 3;
                    L[0] = -L[0].z * L[1] + L[1].z * L[0];
                    L[2] = -L[2].z * L[1] + L[1].z * L[2];
                }
                else if (config == 3) // V1 V2 clip V3 V4

                {
                    n = 4;
                    L[2] = -L[2].z * L[1] + L[1].z * L[2];
                    L[3] = -L[3].z * L[0] + L[0].z * L[3];
                }
                else if (config == 4) // V3 clip V1 V2 V4

                {
                    n = 3;
                    L[0] = -L[3].z * L[2] + L[2].z * L[3];
                    L[1] = -L[1].z * L[2] + L[2].z * L[1];
                }
                else if (config == 5) // V1 V3 clip V2 V4) impossible

                {
                    n = 0;
                }
                else if (config == 6) // V2 V3 clip V1 V4

                {
                    n = 4;
                    L[0] = -L[0].z * L[1] + L[1].z * L[0];
                    L[3] = -L[3].z * L[2] + L[2].z * L[3];
                }
                else if (config == 7) // V1 V2 V3 clip V4

                {
                    n = 5;
                    L[4] = -L[3].z * L[0] + L[0].z * L[3];
                    L[3] = -L[3].z * L[2] + L[2].z * L[3];
                }
                else if (config == 8) // V4 clip V1 V2 V3

                {
                    n = 3;
                    L[0] = -L[0].z * L[3] + L[3].z * L[0];
                    L[1] = -L[2].z * L[3] + L[3].z * L[2];
                    L[2] = L[3];
                }
                else if (config == 9) // V1 V4 clip V2 V3

                {
                    n = 4;
                    L[1] = -L[1].z * L[0] + L[0].z * L[1];
                    L[2] = -L[2].z * L[3] + L[3].z * L[2];
                }
                else if (config == 10) // V2 V4 clip V1 V3) impossible

                {
                    n = 0;
                }
                else if (config == 11) // V1 V2 V4 clip V3

                {
                    n = 5;
                    L[4] = L[3];
                    L[3] = -L[2].z * L[3] + L[3].z * L[2];
                    L[2] = -L[2].z * L[1] + L[1].z * L[2];
                }
                else if (config == 12) // V3 V4 clip V1 V2

                {
                    n = 4;
                    L[1] = -L[1].z * L[2] + L[2].z * L[1];
                    L[0] = -L[0].z * L[3] + L[3].z * L[0];
                }
                else if (config == 13) // V1 V3 V4 clip V2

                {
                    n = 5;
                    L[4] = L[3];
                    L[3] = L[2];
                    L[2] = -L[1].z * L[2] + L[2].z * L[1];
                    L[1] = -L[1].z * L[0] + L[0].z * L[1];
                }
                else if (config == 14) // V2 V3 V4 clip V1

                {
                    n = 5;
                    L[4] = -L[0].z * L[3] + L[3].z * L[0];
                    L[0] = -L[0].z * L[1] + L[1].z * L[0];
                }
                else if (config == 15) // V1 V2 V3 V4

                {
                    n = 4;
                }

                if (n == 3)
                    L[3] = L[0];
                if (n == 4)
                    L[4] = L[0];
            }
            
            float IntegrateEdgeY(float3 v1, float3 v2)
            {
                float x = dot(v1, v2);
                float y = abs(x);

                float a = 0.8543985 + (0.4965155 + 0.0145206 * y) * y;
                float b = 3.4175940 + (4.1616724 + y) * y;
                float v = a / b;

                float theta_sintheta = (x > 0.0) ? v : 0.5 * rsqrt(max(1.0 - x * x, 1e-7)) - v;

                return (cross(v1, v2) * theta_sintheta).y;

                // float cosTheta = dot(v1, v2);
                // float theta = acos(cosTheta);
                // float res = cross(v1, v2).y * ((theta > 0.001) ? theta / sin(theta) : 1.0);

                // return res;

            }

            float IntegrateEdge(float3 v1, float3 v2)
            {
                float x = dot(v1, v2);
                float y = abs(x);

                float a = 0.8543985 + (0.4965155 + 0.0145206 * y) * y;
                float b = 3.4175940 + (4.1616724 + y) * y;
                float v = a / b;

                float theta_sintheta = (x > 0.0) ? v : 0.5 * rsqrt(max(1.0 - x * x, 1e-7)) - v;

                return (cross(v1, v2) * theta_sintheta).z;

                // float cosTheta = dot(v1, v2);
                // float theta = acos(cosTheta);
                // float res = cross(v1, v2).z * theta / sin(theta);
                
                // return res;

            }

            float GaussianKernel(in float x, in float sigma)
            {
                float s = 1 / sigma;
                // 1/sqrt(2 * PI) = 0.39894
                return 0.39894 * exp(-0.5 * x * x * s * s) * s;
            }

            float GaussianInv(float y, float sigma)
            {
                // sqrt(2 * PI) = 2.50662
                return sigma * sqrt(-2 * log(2.50662 * sigma * y));
            }

            float SquareSDF(float2 uv)
            {
                uv -= 0.5;
                float2 st = abs(uv) - 0.5;
                return max(st.x, st.y);
            }

            float3 FilterTexture(sampler2D tex, float3 v0, float3 v1, float3 v2)
            {
                // Reference : Kanikama shader by shivaduke28
                // https://github.com/shivaduke28/kanikama

                // Orthogonal Orojection
                float3 V1 = v0 - v1;
                float3 V2 = v2 - v1;
                float Area = length(cross(V1, V2));
                float3 N = normalize(cross(V1, V2));
                
                float r = dot(v1, N);
                float3 P = r * N - v1;

                // Skew coordinates
                float dotP1V1 = dot(P, V1);
                float dotP1V2 = dot(P, V2);
                float dotV1V1 = dot(V1, V1);
                float dotV2V2 = dot(V2, V2);
                float dotV1V2 = dot(V1, V2);
                float delta = dotV1V1 * dotV2V2 - dotV1V2 * dotV1V2;

                float2 uv;
                uv.y = (dotV2V2 * dotP1V1 - dotV1V2 * dotP1V2) / delta;
                uv.x = (-dotV1V2 * dotP1V1 + dotV1V1 * dotP1V2) / delta;
                uv.y = 1.0 - uv.y;

                // Blur sigma
                float sigma = abs(r) / sqrt(Area);
                float add = max(0, SquareSDF(uv));
                sigma += add;

                // Approximate Gaussian function by step functions.
                // Texture's Filter Mode should be Trilinear.
                float y0 = GaussianKernel(0, sigma);
                float y1 = y0 * 0.75;
                float x1 = GaussianInv(y1, sigma);
                float y2 = y0 * 0.5;
                float x2 = GaussianInv(y2, sigma);
                float y3 = y0 * 0.25;
                float x3 = GaussianInv(y3, sigma);

                half4 col = 0;

                float2 dx = float2(0.5, 0);
                float2 dy = float2(0, 0.5);

                col += tex2Dgrad(tex, uv, dx * x3, dy * x3) * 0.333;
                col += tex2Dgrad(tex, uv, dx * x2, dy * x2) * 0.333;
                col += tex2Dgrad(tex, uv, dx * x1, dy * x1) * 0.333;

                return col;
            }
            
            float3 EvaluateAreaLight(float3 N, float3 V, float3 P, float3x3 Minv, float3 points[4])
            {
                float3 tangent, binormal;
                tangent = normalize(V - N * dot(V, N));
                binormal = cross(N, tangent);

                Minv = mul(transpose(float3x3(tangent, binormal, N)), Minv);

                float3 v[4];
                v[0] = mul(points[0] - P, Minv);
                v[1] = mul(points[1] - P, Minv);
                v[2] = mul(points[2] - P, Minv);
                v[3] = mul(points[3] - P, Minv);

                float3 p[5];
                p[0] = v[0];
                p[1] = v[1];
                p[2] = v[2];
                p[3] = v[3];
                p[4] = 0.0;


                int numPoint;
                ClipQuadToHorizon(p, numPoint);

                if (numPoint == 0)
                    return float3(0, 0, 0);

                p[0] = normalize(p[0]);
                p[1] = normalize(p[1]);
                p[2] = normalize(p[2]);
                p[3] = normalize(p[3]);
                p[4] = normalize(p[4]);

                float integration = 0.0;
                integration += IntegrateEdge(p[0], p[1]);
                integration += IntegrateEdge(p[1], p[2]);
                integration += IntegrateEdge(p[2], p[3]);
                if (numPoint >= 4)
                    integration += IntegrateEdge(p[3], p[4]);
                if (numPoint == 5)
                    integration += IntegrateEdge(p[4], p[0]);

                integration = abs(integration);

                float3 Lo_i = integration;

                if (_UseAreaLightTexture == 1.0)
                {
                    Lo_i *= FilterTexture(_AreaLightTexture, v[0], v[1], v[2]);
                }
                else
                {
                    Lo_i *= _AreaLightColor;
                }

                return Lo_i;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 color = 1.0;

                float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 N = i.normal;

                float cosine = dot(i.normal, V);

                float metallic = _Metallic * tex2D(_MetallicTexture, i.texcoord).r;

                float roughness = _Roughness * tex2D(_RoughnessTexture, i.texcoord).r;

                float3 basecolor = _BaseColor.rgb * tex2D(_BaseColorTexture, i.texcoord).rgb;
                float3 F0 = lerp(float3(0.04, 0.04, 0.04), basecolor, metallic);

                float2 lutUV = GetLUT_Texcoord(cosine, roughness);

                // float4 matrixLut = tex2D(_LTC_LUT, ltcUV);
                float3x3 Minv = GetLTC_InverseMatrix(lutUV, _LTC_LUT);
                
                float3 worldPos = i.worldPos;
                float3 L[4];
                L[0] = _QuadLight_V1;
                L[1] = _QuadLight_V2;
                L[2] = _QuadLight_V3;
                L[3] = _QuadLight_V4;

                float3 specular = EvaluateAreaLight(N, V, worldPos, Minv, L);

                float2 fresnelUV = lutUV;
                float4 fresnelLut = tex2D(_Fresnel_LUT, fresnelUV);
                specular *= F0 * fresnelLut.r + (1.0 - F0) * fresnelLut.g;

                float3 diffuse = EvaluateAreaLight(N, V, worldPos, float3x3(1, 0, 0, 0, 1, 0, 0, 0, 1), L) * basecolor;

                color = specular + diffuse * (1.0 - metallic);
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}

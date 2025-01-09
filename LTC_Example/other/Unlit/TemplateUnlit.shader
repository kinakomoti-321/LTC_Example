Shader "Template/Unlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Color ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        ZWrite On
        Cull Off
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex VertexTemplete
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "./TemplateVertex.hlsl"
            sampler2D _MainTex;
            float4 _Color;

            fixed4 frag(VertexOutputTemplate i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.texcoord0) * _Color;
                
                return fixed4(col.rgb, 1.0);
            }
            ENDCG
        }
    }
}

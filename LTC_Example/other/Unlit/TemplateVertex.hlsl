#ifndef _TEMPLATE_OUTPUTVERTEX_
#define _TEMPLATE_OUTPUTVERTEX_

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
#include "UnityShaderVariables.cginc"

struct Attribute
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float3 tangent : TANGENT;
    float2 texcoord0 : TEXCOORD0;
    float2 texcoord1 : TEXCOORD1;
    float4 colro : COLOR0;
};

struct VertexOutputTemplate
{
    float4 pos : SV_POSITION;
    float3 positionWS : TEXCOORD0;
    float3 positionOS : TEXCOORD1;
    float4 positionSS : TEXCOORD2;
    float3 normalWS : TEXCOORD4;
    float3 tangentWS : TEXCOORD5;
    float2 texcoord0 : TEXCOORD6;
    float2 texcoord1 : TEXCOORD7;

    UNITY_FOG_COORDS(8)
    UNITY_SHADOW_COORDS(9)

    UNITY_VERTEX_OUTPUT_STEREO
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

VertexOutputTemplate VertexTemplete(Attribute v)
{
    VertexOutputTemplate o;
    UNITY_SETUP_INSTANCE_ID(v);
    
    UNITY_INITIALIZE_OUTPUT(VertexOutputTemplate, o);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    o.pos = UnityObjectToClipPos(v.vertex);
    o.positionWS = mul(unity_ObjectToWorld, v.vertex).xyz;
    o.positionOS = v.vertex.xyz;
    o.positionSS = ComputeScreenPos(UnityObjectToClipPos(v.vertex));
    o.normalWS = UnityObjectToWorldNormal(v.normal);
    o.tangentWS = UnityObjectToWorldDir(v.tangent);
    o.texcoord0 = v.texcoord0;
    o.texcoord1 = v.texcoord1;

    UNITY_TRANSFER_FOG(o, o.pos);

    return o;
}

#endif
﻿Shader "HoloLens/SpatialMapping/TiledWall"
{

Properties
{
    _Color("Color", Color) = (1, 1, 1, 1)
    _TilesPerMeter("Tiles per Meter", Float) = 10
    _Mask("Mask", Int) = 1
}

CGINCLUDE

#include "UnityCG.cginc"

struct v2f
{
    float4 vertex : SV_POSITION;
    float3 worldPos : TEXCOORD0;
    UNITY_VERTEX_OUTPUT_STEREO
};

float _TilesPerMeter;
fixed4 _Color;

inline float toIntensity(float3 pos)
{
    return frac(length(pos) - _Time.y);
}

v2f vert(appdata_base v)
{
    v2f o;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex);
    return o;
}

fixed4 frag(v2f i) : SV_Target
{
    float3 worldIndex = floor(i.worldPos.xyz * _TilesPerMeter);
    float3 boxelCenter = worldIndex / _TilesPerMeter;
    float intensity = toIntensity(boxelCenter);
    return _Color * intensity;
}

ENDCG

SubShader
{

Tags 
{ 
    "RenderType"="Opaque" 
    "Queue"="Geometry-1"
}

UsePass "HoloLens/SpatialMapping/Occlusion/OCCLUSION"

Pass
{
    ZWrite Off
    ZTest LEqual
    Blend SrcAlpha OneMinusSrcAlpha 

    Stencil 
    {
        Ref [_Mask]
        Comp NotEqual
    }

    CGPROGRAM
    #pragma vertex vert
    #pragma fragment frag
    #pragma target 5.0
    #pragma only_renderers d3d11
    ENDCG
}

}

}
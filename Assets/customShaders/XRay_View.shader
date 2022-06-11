// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/XRay_View"
{
    Properties
    {
       _Color("Main Color",Color)= (1,1,1,1)
    }
    SubShader
    {

        Tags{"XRay"= "Column"}
       

        Pass
        {
            ColorMask 0
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            uniform half4 _Color;

struct vertexInput
{
    float4  vertex: POSITION;


};
struct vertexOutput{
    float4 pos: SV_POSITION;
};

vertexOutput vert(vertexInput v){
vertexOutput o;

o.pos= UnityObjectToClipPos(v.vertex);

return o;
}
half4 frag(vertexOutput i): SV_TARGET{
    return half4(0.3,0.3,0.3,0);
}
ENDCG
        }
    }

SubShader
    {
        Tags{"XRay"= "Walls" "Queue"="Transparent"}
       

        Pass
        {

            Blend SrcAlpha OneMinusSrcAlpha
            BlendOp Add

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            uniform half4 _Color;

struct vertexInput
{
    float4  vertex: POSITION;


};
struct vertexOutput{
    float4 pos: SV_POSITION;
};

vertexOutput vert(vertexInput v){
vertexOutput o;

o.pos= UnityObjectToClipPos(v.vertex);

return o;
}
half4 frag(vertexOutput i): SV_TARGET{

    return half4(0.5,0.5,0.5,0.8);
    
}
ENDCG
        }

    }
    SubShader
    {

        Tags{"XRay"= "Column"}
       

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            BlendOp Add

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            uniform half4 _Color;

struct vertexInput
{
    float4  vertex: POSITION;


};
struct vertexOutput{
    float4 pos: SV_POSITION;
};

vertexOutput vert(vertexInput v){
vertexOutput o;

o.pos= UnityObjectToClipPos(v.vertex);

return o;
}
half4 frag(vertexOutput i): SV_TARGET{
    return half4(0.3,0.3,0.3,0);
}
ENDCG
        }
    }

SubShader
    {
        Tags{"XRay"= "Floor"}
       

        Pass
        {


            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            uniform half4 _Color;

struct vertexInput
{
    float4  vertex: POSITION;


};
struct vertexOutput{
    float4 pos: SV_POSITION;
};

vertexOutput vert(vertexInput v){
vertexOutput o;

o.pos= UnityObjectToClipPos(v.vertex);

return o;
}
half4 frag(vertexOutput i): SV_TARGET{

    return _Color;
    
}
ENDCG
        }

    }
SubShader
    {
        Tags{"XRay"= "Friend"}
       

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            uniform half4 _Color;

struct vertexInput
{
    float4  vertex: POSITION;


};
struct vertexOutput{
    float4 pos: SV_POSITION;
};

vertexOutput vert(vertexInput v){
vertexOutput o;

o.pos= UnityObjectToClipPos(v.vertex);

return o;
}
half4 frag(vertexOutput i): SV_TARGET{
    return half4(0,1,0,1);
}
ENDCG
        }
    }
SubShader
    {
        Tags{"XRay"= "Enemy" "Queue"="Overlay"}
       

        Pass
        {

           ZTest Always
           ZWrite On

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            uniform half4 _Color;

struct vertexInput
{
    float4  vertex: POSITION;


};
struct vertexOutput{
    float4 pos: SV_POSITION;
};

vertexOutput vert(vertexInput v){
vertexOutput o;

o.pos= UnityObjectToClipPos(v.vertex);

return o;
}
half4 frag(vertexOutput i): SV_TARGET{
    return half4(1,0,0,1);
}


            ENDCG
        }
    }
}

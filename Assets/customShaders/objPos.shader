// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/objPos"
{
    Properties
    {
       //var ("label", dtype)=default
       _Color("Main Color",Color)= (1,1,1,1)
    }
    SubShader
    {
       

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

o.pos= v.vertex;

return o;
}
half4 frag(vertexOutput i): SV_TARGET{
    return _Color;
}




            ENDCG
        }
    }
}

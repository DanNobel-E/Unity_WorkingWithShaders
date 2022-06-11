// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/positionalColor"
{
    Properties
    {
       //var ("label", dtype)=default
       _LeftColor("Left Color",Color)= (1,1,1,1)
       _RightColor("Right Color",Color)= (0,0,0,1)

        

    }
    SubShader
    {
       

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            uniform half4 _LeftColor;
            uniform half4 _RightColor;

struct vertexInput
{
    float4  vertex: POSITION; //vertex position


};
struct vertexOutput{
    float4 pos: SV_POSITION; //Screen view
};

vertexOutput vert(vertexInput v){
vertexOutput o;

o.pos= UnityObjectToClipPos(v.vertex);

return o;
}
half4 frag(vertexOutput i): SV_TARGET{


        float normalY=i.pos.y/_ScreenParams.y;

    if(i.pos.x<_ScreenParams.x*0.5)
    {
        half4 l= _LeftColor;
        l.r*=normalY;
        return l;
    }
    else
    {

        half4 r= _RightColor;
        r.r*=normalY;
        return r;
    }

    
}




            ENDCG
        }
    }
}

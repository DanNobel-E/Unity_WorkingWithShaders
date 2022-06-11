// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/textureLine"
{
    Properties
    {
        
       _Color("Main Color",Color)= (1,1,1,1)
       _Texture("Texture", 2D)= "white"{}
       [Toggle]_HLine("Horizontal Line", Int)=0
       _Start("Start", Range(0,1))=0
       _Width("Width", Range(0,1))=0


    }
    SubShader
    {

        Pass
        {

            Tags{"Queue"="Transparent" "RenderTypre"="Transparent"}
            Blend SrcAlpha OneMinusSrcAlpha
            BlendOp Add

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            uniform half4 _Color;
            uniform sampler2D _Texture;
            uniform float4 _Texture_ST;  //tiling offset
            uniform int _HLine;
            uniform float _Start;
            uniform float _Width;

struct vertexInput
{
    float4  vertex: POSITION;
float4 texcoord: TEXCOORD0;

};
struct vertexOutput{
    float4 pos: SV_POSITION;
    float4 texcoord: TEXCOORD0;
};

float drawLine(float2 uv, float start, float end)
{

if(_HLine==0 && uv.y>start && uv.y<end){

    return 1;

}else if(_HLine==1 && uv.x>start && uv.x<end){

return 1;


}else{
    return 0;
}

}

vertexOutput vert(vertexInput v){

vertexOutput o;
o.pos= UnityObjectToClipPos(v.vertex);
o.texcoord.xy=v.texcoord.xy*_Texture_ST.xy+_Texture_ST.zw;
return o;
}

half4 frag(vertexOutput i): SV_TARGET{

    half4 texColor= tex2D(_Texture, i.texcoord.xy);
    half4 finalColor= half4(_Color*texColor);
    finalColor.a=drawLine(i.texcoord.xy,_Start,_Start+_Width);
    //half4 texColor= tex2Dlod(_Texture, float4(i.texcoord.xyz,_Mipmap));
    return finalColor;
}




            ENDCG
        }
    }
}

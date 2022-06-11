// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/textureFilters"
{
    Properties
    {
       _Color("Main Color",Color)= (1,1,1,1)
       _Texture("Texture", 2D)= "white"{}
       _Samples("Samples", Range(0,1))=0
       _Frequency("Frequency", Float)=1
       _Phase("Phase", Float)=0
       _Amplitude("Amplitude", Float)=1
       [KeywordEnum(0_gradient,1_sin,2_ySymmetry,3_XFlip,4_Pixelate,5_Scan)]_Fx("Fx", Float)=0
    }
    SubShader
    {
            Tags{"Queue"="Transparent" "RenderType"="Transparent"}
       

        Pass
        {


            Blend SrcAlpha OneMinusSrcAlpha
            BlendOp Add

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            uniform half4 _Color;
            uniform sampler2D _Texture;
            uniform float4 _Texture_ST;  //tiling offset
            uniform float _Samples;
            uniform float _Frequency;
            uniform float _Phase;
            uniform float _Amplitude;
            uniform float _Fx;


struct vertexInput
{
    float4  vertex: POSITION;
float4 texcoord: TEXCOORD0;

};
struct vertexOutput{
    float4 pos: SV_POSITION;
    float4 texcoord: TEXCOORD0;
};

vertexOutput vert(vertexInput v){

vertexOutput o;
o.pos= UnityObjectToClipPos(v.vertex);
o.texcoord.xy=v.texcoord.xy*_Texture_ST.xy+_Texture_ST.zw;


return o;
}

half4 frag(vertexOutput i): SV_TARGET{

    half4 texColor=tex2D(_Texture, i.texcoord.xy);

if (_Fx==0){



texColor = tex2D(_Texture, i.texcoord.xy)*i.texcoord.x;
}
else if (_Fx==1){

i.texcoord.x+= sin(i.texcoord.y*_Frequency+_Phase)*_Amplitude;
texColor = tex2D(_Texture, i.texcoord.xy);
}
else if (_Fx==2){

if(i.texcoord.x>_Phase){
    i.texcoord.x= 1-i.texcoord.x;
}
texColor = tex2D(_Texture, i.texcoord.xy);

}
else if (_Fx==3){


i.texcoord.x=1-i.texcoord.x;
texColor = tex2D(_Texture, i.texcoord.xy);


}
else if (_Fx==4){



if(_Samples!=0){
    


float modx= i.texcoord.x/_Samples;
i.texcoord.x= round(modx)*_Samples;

float mody= i.texcoord.y/_Samples;
i.texcoord.y= round(mody)*_Samples;

}

texColor = tex2D(_Texture, i.texcoord.xy);



        }
else if (_Fx==5){

if(_Samples!=0){



    float mod= round(i.texcoord.y/_Samples);
i.texcoord.y= mod*_Samples;

if(fmod(mod,2)==0){
    i.texcoord.x+=_Amplitude;
}else{
    i.texcoord.x-=_Amplitude;

}

}

texColor = tex2D(_Texture, i.texcoord.xy);

    }

    return _Color*texColor;
}




            ENDCG
        }
    }
}

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/textureCircleBorderFade"
{
    Properties
    {
        
       _Color("Main Color",Color)= (1,1,1,1)
       _Texture("Texture", 2D)= "white"{}
       _Center("Center", Vector)= (0.5,0.5,0)
       _RadiusMax("RadiusMax", Range(0,1))=0
       _RadiusMin("RadiusMin", Range(0,1))=0
       _Fade("Fade", Range(0,1))=0



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
            uniform float2 _Center;
            uniform float _RadiusMax;
            uniform float _RadiusMin;
            uniform float _Fade;



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

    half4 texColor= tex2D(_Texture, i.texcoord.xy);
    half4 finalColor= half4(_Color*texColor);
    
    float c_uvDist= pow(_Center.x-i.texcoord.x,2)+pow(_Center.y-i.texcoord.y,2);

    if(c_uvDist<=pow(_RadiusMin,2)){

        finalColor.a=0;
    }
    else if(c_uvDist<=pow(_RadiusMin,2)+pow(_Fade,2) && c_uvDist>pow(_RadiusMin,2)){

         
            finalColor.a= smoothstep(pow(_RadiusMin,2),pow(_RadiusMin,2)+pow(_Fade,2), c_uvDist);


    }else if(c_uvDist<=pow(_RadiusMax,2) -pow(_Fade,2) && c_uvDist>pow(_RadiusMin,2)+pow(_Fade,2)){

            finalColor.a=1;

    }else if(c_uvDist<=pow(_RadiusMax,2) && c_uvDist>pow(_RadiusMax,2)-pow(_Fade,2)){

            finalColor.a= smoothstep(pow(_RadiusMax,2),pow(_RadiusMax,2)-pow(_Fade,2), c_uvDist);
        
    }
    else{
            finalColor.a=0;
    }



    return finalColor;
}




            ENDCG
        }
    }
}

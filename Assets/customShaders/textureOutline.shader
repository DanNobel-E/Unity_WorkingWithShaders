// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/textureOutline"
{
    Properties
    {
        _Color ("MainColor", Color) = (1,1,1,1)
        _Texture ("MainTexture", 2D) = "white" {}
        _OutlineColor ("Outline Color", Color) = (1,1,1,1)
        _OutlineBorder ("Outline Border", Float)=0
        
    }
    SubShader
    {
            Tags {"Queue" = "Transparent" "RenderType" = "Transparent"}

            Pass
        {
            ZWrite Off
            Cull Front
            Blend SrcAlpha OneMinusSrcAlpha
            BlendOp Add

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            uniform half4 _Color;
            uniform sampler2D _Texture;
            uniform float4 _Texture_ST; //tiling offset
            uniform half4 _OutlineColor;
            uniform float _OutlineBorder;

            struct vertexInput
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };
            struct vertexOutput
            {
                float4 pos : SV_POSITION;
                float4 texcoord : TEXCOORD0;
            };

            vertexOutput vert(vertexInput v)
            {
                vertexOutput o;


                float4x4 scaleM= float4x4( 
                            _OutlineBorder,0,0,0,
                            0, _OutlineBorder,0,0,
                            0,0,_OutlineBorder,0,
                            0,0,0,1
                            );

               
               float4 scaledObjPos = mul(scaleM, v.vertex);

                o.pos=UnityObjectToClipPos(scaledObjPos);


                return o;
            }

            half4 frag(vertexOutput i): SV_Target
            {
                
                return _OutlineColor;
            }

            ENDCG
        }
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
            uniform float4 _Texture_ST; //tiling offset

            struct vertexInput
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };
            struct vertexOutput
            {
                float4 pos : SV_POSITION;
                float4 texcoord : TEXCOORD0;
            };

            vertexOutput vert(vertexInput v)
            {
                vertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.texcoord.xy = v.texcoord.xy * _Texture_ST.xy + _Texture_ST.zw;

                return o;
            }

            half4 frag(vertexOutput i): SV_Target
            {
                half4 texColor = tex2D(_Texture, i.texcoord.xy);
                return _Color * texColor;
            }

            ENDCG
        }
    }
}

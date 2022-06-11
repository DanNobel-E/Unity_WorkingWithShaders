Shader "Custom/glass"
{
    Properties
    {
        _Color ("MainColor", Color) = (1,1,1,1)
        _MainTexture ("MainTexture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "white" {}
        [KeywordEnum(Off,On)] _UseNormal("Use Normal Map", Float) = 0

        _Diffuse("Diffuse", Range(0,1)) = 1
        [KeywordEnum(Off,Vert,Frag)] _Lighting("LightingMode", Float) = 0

        _SpecularMap ("Specular Map", 2D) = "white" {}
        _Specular("Specular", Range(0,1)) = 1
        _SpecularPower("SpecularPower", Float) = 10

        [Toggle] _AmbientMode("AmbientLighting", Float) = 0
        _Ambient ("Ambient", Range(0,1)) = 1

        _Distortion("Distortion", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags {"Queue" = "Transparent" "RenderType" = "Transparent"}

        GrabPass{"_BackgroundTexture"}

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            Blend SrcAlpha OneMinusSrcAlpha
            BlendOp Add

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #pragma shader_feature _USENORMAL_ON _USENORMAL_OFF
            #pragma shader_feature _LIGHTING_OFF _LIGHTING_VERT _LIGHTING_FRAG
            #pragma shader_feature _AMBIENTMODE_OFF _AMBIENTMODE_ON

            #include "UnityCG.cginc"
            #include "CGLighting.cginc"

            uniform half4 _Color;
            uniform sampler2D _MainTexture;
            uniform float4 _MainTexture_ST; //tiling offset
            uniform sampler2D _NormalMap;
            uniform float4 _NormalMap_ST; //tiling offset

            uniform float _Diffuse;
            uniform float4 _LightColor0;

            uniform sampler2D _SpecularMap;
            uniform float _Specular;
            uniform float _SpecularPower;
            uniform float _Ambient;

            uniform sampler2D _BackgroundTexture;
            uniform float _Distortion;
            

            struct vertexInput
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
                float4 normal : NORMAL;
                #if _USENORMAL_ON                
                    float4 tangent : TANGENT;
                #endif
            };
            struct vertexOutput
            {
                float4 pos : SV_POSITION;
                float4 texcoord : TEXCOORD0;
                float4 normalWorld : TEXCOORD1;

                #if _USENORMAL_ON                
                    float4 tangentWorld : TEXCOORD2;
                    float3 binormalWorld : TEXCOORD3; //cross defined for 3 or 7 dimensions
                    float4 normalTexCoord : TEXCOORD4;
                #endif

                #if _LIGHTING_VERT
                    float4 surfaceColor : COLOR0;
                #endif
                #if _LIGHTING_FRAG
                    float4 posWorld : TEXCOORD5;
                #endif

                float4 texcoordGrab : TEXCOORD6;
            };

            float3 DiffuseLambert(float3 n, float3 lightDir, float3 lightCol, float diffuseFactor, float attenuation)
            {
                return lightCol * diffuseFactor * attenuation * max(0, dot(n, lightDir));
            }

            float3 SpecularBlinnPhong(float3 n, float3 lightDir, float3 V, float3 specularCol, float specularFactor, float specularPower, float attenuation)
            {
                float3 H = normalize(lightDir + V);
                return specularCol * specularFactor * attenuation * pow(max(0, dot(n, H)), specularPower);
            }

            vertexOutput vert(vertexInput v)
            {
                vertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.texcoord.xy = v.texcoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw;
                o.normalWorld = float4(UnityObjectToWorldNormal(v.normal.xyz), v.normal.w);

                o.texcoordGrab = ComputeGrabScreenPos(o.pos);

                #if _USENORMAL_ON                
                o.tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
                o.binormalWorld = float3(normalize(cross(o.normalWorld.xyz, o.tangentWorld.xyz) * v.tangent.w)); //UV Flip correction
                o.binormalWorld *= unity_WorldTransformParams.w;
                o.normalTexCoord.xy = v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
                #endif

                #if _LIGHTING_VERT
                    float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                    float3 lightColor = _LightColor0.xyz;
                    float attenuation = 1;
                    o.surfaceColor = float4(DiffuseLambert(o.normalWorld, lightDir, lightColor, _Diffuse, attenuation), 1);
                #endif

                #if _LIGHTING_FRAG
                    o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                #endif

                return o;
            }
            
            

            half4 frag(vertexOutput i): SV_Target
            {
                float4 finalColor;

                half4 texColor = tex2D(_MainTexture, i.texcoord.xy);
                float3 normalWorldAtPixel;
                
                #if _USENORMAL_ON                
                    half4 normalColor = tex2D(_NormalMap, i.normalTexCoord.xy);
                    float3 TSNormal = normalFromColor(normalColor);
                    float3x3 TBNWorld = float3x3(   i.tangentWorld.x, i.binormalWorld.x, i.normalWorld.x,
                                                    i.tangentWorld.y, i.binormalWorld.y, i.normalWorld.y,
                                                    i.tangentWorld.z, i.binormalWorld.z, i.normalWorld.z);
                    normalWorldAtPixel = normalize(mul(TBNWorld, TSNormal));
                    finalColor = float4(normalWorldAtPixel.xyz,1);
                #else
                    normalWorldAtPixel = i.normalWorld.xyz;
                    finalColor = float4(i.normalWorld.xyz,1);
                #endif

                float2 distortion = _Distortion * TSNormal.xy;
                i.texcoordGrab.xy += distortion;
                float4 grabColor = tex2Dproj(_BackgroundTexture, i.texcoordGrab);
                texColor *= grabColor;

                #if _LIGHTING_FRAG
                    //Diffuse
                    float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                    float3 lightColor = _LightColor0;
                    float attenuation = 1;
                    float3 diffuse = DiffuseLambert(normalWorldAtPixel, lightDir, lightColor, _Diffuse, attenuation);
                    //specular
                    float3 V = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                    float3 specularColor = tex2D(_SpecularMap, i.texcoord.xy);
                    float3 specular = SpecularBlinnPhong(normalWorldAtPixel, lightDir, V, specularColor, _Specular, _SpecularPower, attenuation);
                    #if _AMBIENTMODE_ON
                        //ambient
                        float ambient = _Ambient * UNITY_LIGHTMODEL_AMBIENT;
                        finalColor = float4(texColor*diffuse + specular + ambient, texColor.a);
                    #else
                        finalColor = float4(texColor*diffuse + specular, texColor.a);
                    #endif

                #elif _LIGHTING_VERT
                    finalColor = i.surfaceColor;
                #endif

                return finalColor * _Color;
            }

            ENDCG
        }
    }
}

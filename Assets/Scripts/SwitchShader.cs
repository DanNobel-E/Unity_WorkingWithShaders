using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum ST { Off, On}
public class SwitchShader : MonoBehaviour
{
    public ST SeeThrough;
    public GameObject Obj;

    Shader STOn;
    Shader STOff;
    Material mat;
    // Start is called before the first frame update
    void Start()
    {
        STOn = Shader.Find("Custom/lightingRimLightSTOn");
        STOff = Shader.Find("Custom/lightingRimLightSTOff");
        mat = Obj.GetComponent<MeshRenderer>().sharedMaterial;
    }

    // Update is called once per frame
    void Update()
    {
        switch (SeeThrough)
        {
            case ST.Off:
                if (mat.shader != STOff)
                {
                    mat.shader = STOff;
                }
                break;
            case ST.On:
                if (mat.shader != STOn)
                {
                    mat.shader = STOn;
                }
                break;
        }

    }
}

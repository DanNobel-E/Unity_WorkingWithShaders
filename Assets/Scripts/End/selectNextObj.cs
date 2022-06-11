using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class selectNextObj : MonoBehaviour {
    public KeyCode nextKey;
    public GameObject selectableObjRoot;
    public Texture2D Texture;
    public Color OutlineColor;
    public Color OutlineColor2;
    GameObject[] selectableObjs;
    GameObject currObjSelected;
    int currIndex = 0;
    Shader objSelShader, objNotSelShader;
    Material currObjSelSMat;
    public float currBorder;
    [Range(0.1f,1)]
    public float currBorder2;


    void Start () {
        selectableObjs = new GameObject[selectableObjRoot.transform.childCount];
        for (int i = 0; i < selectableObjs.Length; i++)
        {
            selectableObjs[i] = selectableObjRoot.transform.GetChild(i).gameObject;
            }

        objSelShader = Shader.Find("Custom/textureDoubleOutline");
        objNotSelShader = Shader.Find("Custom/texture");
    }

    void Update () {
        if (Input.GetKeyDown(nextKey))
        {

            if (currObjSelected == null)
            {
                currObjSelected = selectableObjs[currIndex];
             }
            else
            {
                currObjSelSMat.shader = objNotSelShader;


                currIndex++;
                if (currIndex >= selectableObjs.Length)
                    currIndex = 0;

                currObjSelected = selectableObjs[currIndex];

            }


            currObjSelSMat = currObjSelected.GetComponent<MeshRenderer>().material;
            currObjSelSMat.shader = objSelShader;
            currObjSelSMat.SetColor("_OutlineColor", OutlineColor);
            currObjSelSMat.SetColor("_OutlineColor2", OutlineColor2);


        }

        if (currObjSelected != null)
        {
            currObjSelSMat.SetFloat("_OutlineBorder", (Mathf.Abs(Mathf.Sin(Time.time * 5))) * currBorder);
            currObjSelSMat.SetFloat("_OutlineBorder2", currBorder2);

        }
    }

    private void OnDestroy()
    {
        for (int i = 0; i < selectableObjs.Length; i++)
            selectableObjs[i].GetComponent<Renderer>().sharedMaterial.shader = objNotSelShader;
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AreaLightSet : MonoBehaviour
{
    public Vector3 _AreaLight_v1 = new Vector3(0.0f, 0.0f, 0.0f);
    public Vector3 _AreaLight_v2 = new Vector3(0.0f, 0.0f, 0.0f);
    public Vector3 _AreaLight_v3 = new Vector3(0.0f, 0.0f, 0.0f);
    public Vector3 _AreaLight_v4 = new Vector3(0.0f, 0.0f, 0.0f);

    public Color _AreaLightColor;
    public Texture2D _AreaLightTexture;

    void Start()
    {

    }

    void Update()
    {
        Material material = GetComponent<Renderer>().material;
        material.SetVector("_QuadLight_V1", _AreaLight_v1);
        material.SetVector("_QuadLight_V2", _AreaLight_v2);
        material.SetVector("_QuadLight_V3", _AreaLight_v3);
        material.SetVector("_QuadLight_V4", _AreaLight_v4);
        material.SetColor("_AreaLightColor", _AreaLightColor);
        if (_AreaLightTexture != null) material.SetFloat("_UseAreaLightTexture", 1.0f);
        else material.SetFloat("_UseAreaLightTexture", 0.0f);
        material.SetTexture("_AreaLightTexture", _AreaLightTexture);
    }
}

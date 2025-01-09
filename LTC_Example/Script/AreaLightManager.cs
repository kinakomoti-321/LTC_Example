using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AreaLightManager : MonoBehaviour
{
    // Start is called before the first frame update
    public AreaLightSet[] _AreaLightSets;

    public Color _AreaLightColor;
    public Texture2D _AreaLightTexture;

    void Start()
    {
        _AreaLightColor = new Color(1.0f, 1.0f, 1.0f, 1.0f);
    }

    // Update is called once per frame
    void Update()
    {
        Mesh mesh = GetComponent<MeshFilter>().mesh;
        Vector3[] vertices = mesh.vertices;
        Vector3[] worldVertices = new Vector3[vertices.Length];

        for (int i = 0; i < vertices.Length; i++)
        {
            worldVertices[i] = transform.TransformPoint(vertices[i]);
        }

        for (int i = 0; i < _AreaLightSets.Length; i++)
        {
            AreaLightSet areaLightSet = _AreaLightSets[i];
            areaLightSet._AreaLight_v1 = worldVertices[0];
            areaLightSet._AreaLight_v2 = worldVertices[1];
            areaLightSet._AreaLight_v3 = worldVertices[2];
            areaLightSet._AreaLight_v4 = worldVertices[3];
            areaLightSet._AreaLightColor = _AreaLightColor;
            areaLightSet._AreaLightTexture = _AreaLightTexture;
        }

        Material material = GetComponent<Renderer>().material;
        material.SetColor("_Color", _AreaLightColor);
        material.SetTexture("_MainTex", _AreaLightTexture);
    }
}

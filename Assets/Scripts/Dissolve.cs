using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Dissolve : MonoBehaviour {

	public float dissolve = 0f;

	void Start () {
		
	}
	
	void Update () {
		Shader.SetGlobalFloat("_Dissolve", dissolve);
	}
}

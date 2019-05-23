using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Grow : MonoBehaviour {

	public Material filter;
	public Transform target;

	private RenderTexture renderTexture;

	void Start () {
		renderTexture = new RenderTexture(128, 128, 24, RenderTextureFormat.ARGBFloat);
		renderTexture.Create();
	}
	
	void Update () {
		Shader.SetGlobalVector("_Target", target.position);
		Graphics.Blit(null, renderTexture, filter);
		Shader.SetGlobalTexture("_GrassMap", renderTexture);
	}
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Grow : MonoBehaviour {

	public Material filter;
	public Transform target;

	private RenderTexture[] renderTexture;
	private int currentTexture;

	void Start () {
		currentTexture = 0;
		renderTexture = new RenderTexture[2];
		for (int i = 0; i < 2; ++i) {
			renderTexture[i] = new RenderTexture(128, 128, 24, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
			renderTexture[i].Create();
		}
	}
	
	void Update () {
		Shader.SetGlobalVector("_Target", target.position);

		int nextTexture = (currentTexture + 1) % 2;
		Graphics.Blit(renderTexture[currentTexture], renderTexture[nextTexture], filter);
		filter.SetTexture("_GrassMap", renderTexture[currentTexture]);
		Shader.SetGlobalTexture("_GrassMap", renderTexture[currentTexture]);

		currentTexture = (currentTexture + 1) % 2;
	}
}

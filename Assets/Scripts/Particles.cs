
using System.IO;
using System.Reflection;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;

public class Particles : MonoBehaviour
{
	public ComputeShader compute;
	public Material material;
	public Transform target;
	public int particleCount = 100000;
	public float _Radius = 0.1f;
	public float _Speed = 0.1f;
	public float _Friction = 0.9f;
	public float _NoiseScale = 1f;
	public float _BlendCurl = 0.5f;
	public float _BlendGravity = 0f;
	public float _BlendTarget = 0.5f;

	private struct ParticleData { public Vector3 position, velocity, seed; }
	private ParticleData[] particles;
	private ComputeBuffer particleBuffer;

	void Start ()
	{
		// Create points
		Vector3[] vertices = new Vector3[particleCount];
		Vector3[] seeds = new Vector3[particleCount];
		for (int i = 0; i < particleCount; ++i) {
			vertices[i] = Random.onUnitSphere * 5f;
			seeds[i] = Random.onUnitSphere;
		}
		
		// Create mesh
		int sliceX = 2;
		int sliceY = 1;
		Mesh mesh = Geometry.Particles(vertices, null, null, sliceX, sliceY);
		mesh.bounds = new Bounds(Vector3.zero, Vector3.one * 100f);
		gameObject.AddComponent<MeshFilter>().mesh = mesh;
		gameObject.AddComponent<MeshRenderer>().material = material;

		particles = new ParticleData[particleCount];
		for (int i = 0; i < particleCount; ++i) {
			particles[i].position = vertices[i];
			particles[i].velocity = Vector3.zero;
			particles[i].seed = seeds[i];
		}

		particleBuffer = new ComputeBuffer(particles.Length, Marshal.SizeOf(typeof(ParticleData)));
		particleBuffer.SetData(particles);
		SetBuffer("_Particles", particleBuffer);
	}

	void Update ()
	{
		SetFloat("_Count", particleCount);
		SetFloat("_TimeElapsed", Time.time);
		SetFloat("_Speed", _Speed);
		SetFloat("_Radius", _Radius);
		SetFloat("_Friction", _Friction);
		SetFloat("_NoiseScale", _NoiseScale);
		SetFloat("_BlendCurl", _BlendCurl);
		SetFloat("_BlendGravity", _BlendGravity);
		SetFloat("_BlendTarget", _BlendTarget);
		SetFloat("_TimeDelta", Time.deltaTime);
		SetVector("_Target", target.position);
		SetMatrix("_MatrixWorld", transform.localToWorldMatrix);
		SetMatrix("_MatrixLocal", transform.worldToLocalMatrix);

		#if UNITY_EDITOR
		SetBuffer("_Particles", particleBuffer);
		#endif

		compute.Dispatch(0, particles.Length/8, 1, 1);
	}

	void SetVector(string name, Vector3 v) {
		material.SetVector(name, v);
		compute.SetVector(name, v);
	}

	void SetFloat(string name, float v) {
		material.SetFloat(name, v);
		compute.SetFloat(name, v);
	}

	void SetTexture(string name, Texture v) {
		material.SetTexture(name, v);
		compute.SetTexture(0, name, v);
	}

	void SetMatrix(string name, Matrix4x4 v) {
		material.SetMatrix(name, v);
		compute.SetMatrix(name, v);
	}

	void SetBuffer(string name, ComputeBuffer v) {
		material.SetBuffer(name, v);
		if (v != null) compute.SetBuffer(0, name, v);
	}

	void OnDestroy () {
		if (particleBuffer != null) particleBuffer.Dispose();
	}
}

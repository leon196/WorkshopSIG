
using System.IO;
using System.Reflection;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;

public class Particles : MonoBehaviour
{
	public ComputeShader compute;
	public ParticlesProfile particleProfile;
	public Material material;
	public int particleCount = 100000;
	public int segments = 1;
	public Transform center;

	private Mesh meshToClone;
	private string[] uniformsProfile;
	private FieldInfo[] profileFields;

	private struct PointData { public Vector3 position, velocity, info, seed; }
	private struct TrailData { public Vector3 position; }
	private PointData[] particles;
	private TrailData[] trails;
	private ComputeBuffer particleBuffer, trailBuffer;
	[HideInInspector] public bool resetBuffer = false;

	private Vector3[] GetSpawnPositions () {
		Vector3[] vertices = new Vector3[particleCount];
		for (int i = 0; i < particleCount; ++i) {
			// vertices[i] = Random.onUnitSphere;
			vertices[i] = new Vector3(Random.Range(-4f, 4f), 0f, Random.Range(-4f, 4f));
		}
		return vertices;
	}

	void Start ()
	{
		profileFields = particleProfile.GetType().GetFields();
		uniformsProfile = new string[profileFields.Length];
		for (int i = 0; i < profileFields.Length; ++i) uniformsProfile[i] = profileFields[i].Name;

		Vector3[] verticesToClone = new Vector3[particleCount];
		Vector3[] normalsToClone = new Vector3[particleCount];
		Color[] colors = new Color[particleCount];
		for (int i = 0; i < particleCount; ++i) {
			verticesToClone[i] = Random.onUnitSphere * 100f;
			normalsToClone[i] = new Vector3(0,1,0);
			colors[i] = new Color(1,1,1,1);
		}
		
		Mesh mesh = Geometry.Particles(verticesToClone, colors, normalsToClone, segments);
		mesh.bounds = new Bounds(Vector3.zero, Vector3.one * 100f);
		gameObject.AddComponent<MeshFilter>().mesh = mesh;
		gameObject.AddComponent<MeshRenderer>().material = material;

		particleCount = verticesToClone.Length;
		particles = new PointData[particleCount];
		trails = new TrailData[particleCount*segments];
		Vector3[] vertices = GetSpawnPositions();
		Vector3[] normals = normalsToClone;
		for (int i = 0; i < particleCount; ++i) {
			particles[i].position = vertices[i];
			particles[i].velocity = Vector3.zero;
			particles[i].info = Vector3.zero;
			particles[i].seed = Random.insideUnitSphere;
		}
		for (int i = 0; i < particleCount; i++)
			for (int h = 0; h < segments; ++h)
				trails[i*segments+h].position = particles[i].position;

		particleBuffer = new ComputeBuffer(particles.Length, Marshal.SizeOf(typeof(PointData)));
		trailBuffer = new ComputeBuffer(trails.Length, Marshal.SizeOf(typeof(TrailData)));
		particleBuffer.SetData(particles);
		trailBuffer.SetData(trails);
		SetBuffer("_Particles", particleBuffer);
		SetBuffer("_Trails", trailBuffer);
	}

	void Update ()
	{
		if (Input.GetKeyDown(KeyCode.R)) {
			resetBuffer = true;
			Vector3[] vertices = GetSpawnPositions();
			for (int i = 0; i < particleCount; ++i) {
				particles[i].position = vertices[i];
				particles[i].velocity = Vector3.zero;
				particles[i].info = Vector3.zero;
				particles[i].seed = Random.insideUnitSphere;
			}
			for (int i = 0; i < particleCount; i++)
				for (int h = 0; h < segments; ++h)
					trails[i*segments+h].position = particles[i].position;
			particleBuffer.SetData(particles);
			trailBuffer.SetData(trails);
		}

		SetFloat("_Count", particleCount);
		SetFloat("_Segments", segments);
		SetFloat("_TimeElapsed", Time.time);
		SetFloat("_TimeDelta", Time.deltaTime);
		SetFloat("_ResetBuffer", resetBuffer?1f:0f);
		SetMatrix("_MatrixWorld", transform.localToWorldMatrix);
		SetMatrix("_MatrixLocal", transform.worldToLocalMatrix);

		if (center != null) SetVector("_Center", center.position);

		#if UNITY_EDITOR
		SetBuffer("_Particles", particleBuffer);
		SetBuffer("_Trails", trailBuffer);
		#endif

		for (int i = 0; i < profileFields.Length; ++i)
			SetFloat(uniformsProfile[i], (float)profileFields[i].GetValue(particleProfile));

		compute.Dispatch(0, particles.Length/8, 1, 1);
		compute.Dispatch(1, trails.Length/8, 1, 1);

		resetBuffer = false;
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
		compute.SetTexture(1, name, v);
	}

	void SetMatrix(string name, Matrix4x4 v) {
		material.SetMatrix(name, v);
		compute.SetMatrix(name, v);
	}

	void SetBuffer(string name, ComputeBuffer v) {
		material.SetBuffer(name, v);
		if (v != null) compute.SetBuffer(0, name, v);
		if (v != null) compute.SetBuffer(1, name, v);
	}

	void OnDestroy () {
		if (particleBuffer != null) particleBuffer.Dispose();
		if (trailBuffer != null) trailBuffer.Dispose();
	}
}

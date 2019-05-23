using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;

[CreateAssetMenu(fileName = "Data", menuName = "Particles Profile", order = 100)]
public class ParticlesProfile : ScriptableObject
{
	[Header("Display")]
	public float _Radius = 0.05f;
	[Range(0,1)] public float _RadiusVariance = .9f;
	public float _StretchX = 1f;
	public float _StretchY = 1f;
	[Range(0,1)] public float _TrailDamping = .25f;
	[Header("Light")]
	[Range(0,1)] public float _Glossiness = 0f;
	[Range(0,10)] public float _Emission = 0f;
	[Range(0,1)] public float _Metallic = 0f;
	[Header("Physics")]
	public float _Speed = 0.1f;
	[Range(0,1)] public float _Friction = 0.9f;
	public float _NoiseScale = 2f;
	[Header("Area")]
	public float _EmitterRadius = 2f;
	[Header("Morph")]
	[Range(0,1)] public float _MorphSphere = 0f;
	[Header("Forces")]
	[Range(0,1)] public float _BlendCurl = 1f;
	[Range(0,1)] public float _BlendAttract = 1f;
	[Range(0,1)] public float _BlendKinect = 1f;
	[Range(0,1)] public float _BlendTwist = 1f;
	[Range(0,1)] public float _BlendInitial = 1f;
	[Range(-1,1)] public float _BlendGravity = 1f;
}
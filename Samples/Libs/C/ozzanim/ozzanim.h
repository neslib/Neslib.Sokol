// Quick & Dirty partial C wrapper for ozz-animation

#if _WIN32
#define OZZ_API __declspec(dllexport)
#else
#define OZZ_API
#endif

#include <stdio.h>
#include <stdint.h>

#if defined(__cplusplus)
extern "C" {
#endif

typedef void* ozz_handle_t;

struct ozz_span_t {
  void* data;
  size_t size;
};

// Skeleton

OZZ_API ozz_handle_t Skeleton_Create();
OZZ_API void Skeleton_Destroy(ozz_handle_t instance);
OZZ_API int Skeleton_NumJoints(ozz_handle_t instance);
OZZ_API int Skeleton_NumSoaJoints(ozz_handle_t instance);
OZZ_API void Skeleton_JointParents(ozz_handle_t instance, struct ozz_span_t* parents);

// Animation

OZZ_API ozz_handle_t Animation_Create();
OZZ_API void Animation_Destroy(ozz_handle_t instance);
OZZ_API float Animation_Duration(ozz_handle_t instance);

// Mesh

OZZ_API ozz_handle_t Mesh_Create();
OZZ_API void Mesh_Destroy(ozz_handle_t instance);
OZZ_API int Mesh_NumParts(ozz_handle_t instance);
OZZ_API ozz_handle_t Mesh_GetPart(ozz_handle_t instance, int index);
OZZ_API int Mesh_NumJoints(ozz_handle_t instance);
OZZ_API uint16_t* Mesh_GetTriangleIndices(ozz_handle_t instance, int* count);
OZZ_API uint16_t* Mesh_GetJointRemaps(ozz_handle_t instance, int* count);
OZZ_API void* Mesh_GetInverseBindPoses(ozz_handle_t instance, int* count);

// MeshPart

OZZ_API float* MeshPart_GetPositions(ozz_handle_t instance, int* count);
OZZ_API float* MeshPart_GetNormals(ozz_handle_t instance, int* count);
OZZ_API uint16_t* MeshPart_GetJointIndices(ozz_handle_t instance, int* count);
OZZ_API float* MeshPart_GetJointWeights(ozz_handle_t instance, int* count);

// SamplingCache

OZZ_API ozz_handle_t SamplingCache_Create();
OZZ_API void SamplingCache_Destroy(ozz_handle_t instance);
OZZ_API void SamplingCache_Resize(ozz_handle_t instance, int max_tracks);

// SamplingJob

OZZ_API ozz_handle_t SamplingJob_Create();
OZZ_API void SamplingJob_Destroy(ozz_handle_t instance);
OZZ_API void SamplingJob_SetAnimation(ozz_handle_t instance, ozz_handle_t animation);
OZZ_API void SamplingJob_SetCache(ozz_handle_t instance, ozz_handle_t cache);
OZZ_API void SamplingJob_SetRatio(ozz_handle_t instance, float ratio);
OZZ_API void SamplingJob_SetOutput(ozz_handle_t instance, struct ozz_span_t span);
OZZ_API void SamplingJob_Run(ozz_handle_t instance);

// LocalToModelJob

OZZ_API ozz_handle_t LocalToModelJob_Create();
OZZ_API void LocalToModelJob_Destroy(ozz_handle_t instance);
OZZ_API void LocalToModelJob_SetSkeleton(ozz_handle_t instance, ozz_handle_t skeleton);
OZZ_API void LocalToModelJob_SetInput(ozz_handle_t instance, struct ozz_span_t span);
OZZ_API void LocalToModelJob_SetOutput(ozz_handle_t instance, struct ozz_span_t span);
OZZ_API void LocalToModelJob_Run(ozz_handle_t instance);

// Stream

OZZ_API size_t Stream_Write(ozz_handle_t instance, const void* buffer, size_t size);
OZZ_API int Stream_Seek(ozz_handle_t instance, int offset, int origin);

// MemoryStream

OZZ_API ozz_handle_t MemoryStream_Create();
OZZ_API void MemoryStream_Destroy(ozz_handle_t instance);

// IArchive

OZZ_API ozz_handle_t IArchive_Create(ozz_handle_t stream);
OZZ_API void IArchive_Destroy(ozz_handle_t instance);
OZZ_API int IArchive_TestTag_Skeleton(ozz_handle_t instance);
OZZ_API void IArchive_Load_Skeleton(ozz_handle_t instance, ozz_handle_t skeleton);
OZZ_API int IArchive_TestTag_Animation(ozz_handle_t instance);
OZZ_API void IArchive_Load_Animation(ozz_handle_t instance, ozz_handle_t animation);
OZZ_API int IArchive_TestTag_Mesh(ozz_handle_t instance);
OZZ_API void IArchive_Load_Mesh(ozz_handle_t instance, ozz_handle_t mesh);

#if defined(__cplusplus)
} // extern "C"
#endif

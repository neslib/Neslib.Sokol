#include "ozzanim.h"
#include "ozz/animation/runtime/skeleton.h"
#include "ozz/animation/runtime/animation.h"
#include "ozz/animation/runtime/sampling_job.h"
#include "ozz/animation/runtime/local_to_model_job.h"
#include "ozz/base/io/stream.h"
#include "ozz/base/io/archive.h"
#include "ozz/util/mesh.h"

// Skeleton

OZZ_API ozz_handle_t Skeleton_Create()
{
  return new ozz::animation::Skeleton();
}

OZZ_API void Skeleton_Destroy(ozz_handle_t instance)
{
  assert(instance);
  ozz::animation::Skeleton* self = (ozz::animation::Skeleton*)instance;
  delete self;
}

OZZ_API int Skeleton_NumJoints(ozz_handle_t instance)
{
  assert(instance);
  ozz::animation::Skeleton* self = (ozz::animation::Skeleton*)instance;
  return self->num_joints();
}

OZZ_API int Skeleton_NumSoaJoints(ozz_handle_t instance)
{
  assert(instance);
  ozz::animation::Skeleton* self = (ozz::animation::Skeleton*)instance;
  return self->num_soa_joints();
}

OZZ_API void Skeleton_JointParents(ozz_handle_t instance, struct ozz_span_t* parents)
{
  assert(instance);
  ozz::animation::Skeleton* self = (ozz::animation::Skeleton*)instance;
  ozz::span<const int16_t> s = self->joint_parents();
  parents->data = (void*)s.data();
  parents->size = s.size();
}

// Animation

OZZ_API ozz_handle_t Animation_Create()
{
  return new ozz::animation::Animation();
}

OZZ_API void Animation_Destroy(ozz_handle_t instance)
{
  assert(instance);
  ozz::animation::Animation* self = (ozz::animation::Animation*)instance;
  delete self;
}

OZZ_API float Animation_Duration(ozz_handle_t instance)
{
  assert(instance);
  ozz::animation::Animation* self = (ozz::animation::Animation*)instance;
  return self->duration();
}

// Mesh

OZZ_API ozz_handle_t Mesh_Create()
{
  return new ozz::sample::Mesh();
}

OZZ_API void Mesh_Destroy(ozz_handle_t instance)
{
  assert(instance);
  ozz::sample::Mesh* self = (ozz::sample::Mesh*)instance;
  delete self;
}

OZZ_API int Mesh_NumParts(ozz_handle_t instance)
{
  assert(instance);
  ozz::sample::Mesh* self = (ozz::sample::Mesh*)instance;
  return self->parts.size();
}

OZZ_API ozz_handle_t Mesh_GetPart(ozz_handle_t instance, int index)
{
  assert(instance);
  ozz::sample::Mesh* self = (ozz::sample::Mesh*)instance;
  return (ozz_handle_t)&self->parts[index];
}

OZZ_API int Mesh_NumJoints(ozz_handle_t instance)
{
  assert(instance);
  ozz::sample::Mesh* self = (ozz::sample::Mesh*)instance;
  return self->num_joints();
}

OZZ_API uint16_t* Mesh_GetTriangleIndices(ozz_handle_t instance, int* count)
{
  assert(instance);
  assert(count);
  ozz::sample::Mesh* self = (ozz::sample::Mesh*)instance;
  *count = self->triangle_indices.size();
  return self->triangle_indices.data();
}

OZZ_API uint16_t* Mesh_GetJointRemaps(ozz_handle_t instance, int* count)
{
  assert(instance);
  assert(count);
  ozz::sample::Mesh* self = (ozz::sample::Mesh*)instance;
  *count = self->joint_remaps.size();
  return self->joint_remaps.data();
}

OZZ_API void* Mesh_GetInverseBindPoses(ozz_handle_t instance, int* count)
{
  assert(instance);
  assert(count);
  ozz::sample::Mesh* self = (ozz::sample::Mesh*)instance;
  *count = self->inverse_bind_poses.size();
  return self->inverse_bind_poses.data();
}

// MeshPart

OZZ_API float* MeshPart_GetPositions(ozz_handle_t instance, int* count)
{
  assert(instance);
  assert(count);
  ozz::sample::Mesh::Part* self = (ozz::sample::Mesh::Part*)instance;
  *count = self->positions.size();
  return self->positions.data();
}

OZZ_API float* MeshPart_GetNormals(ozz_handle_t instance, int* count)
{
  assert(instance);
  assert(count);
  ozz::sample::Mesh::Part* self = (ozz::sample::Mesh::Part*)instance;
  *count = self->normals.size();
  return self->normals.data();
}

OZZ_API uint16_t* MeshPart_GetJointIndices(ozz_handle_t instance, int* count)
{
  assert(instance);
  assert(count);
  ozz::sample::Mesh::Part* self = (ozz::sample::Mesh::Part*)instance;
  *count = self->joint_indices.size();
  return self->joint_indices.data();
}

OZZ_API float* MeshPart_GetJointWeights(ozz_handle_t instance, int* count)
{
  assert(instance);
  assert(count);
  ozz::sample::Mesh::Part* self = (ozz::sample::Mesh::Part*)instance;
  *count = self->joint_weights.size();
  return self->joint_weights.data();
}

// SamplingCache

OZZ_API ozz_handle_t SamplingCache_Create()
{
  return new ozz::animation::SamplingCache();
}

OZZ_API void SamplingCache_Destroy(ozz_handle_t instance)
{
  assert(instance);
  ozz::animation::SamplingCache* self = (ozz::animation::SamplingCache*)instance;
  delete self;
}

OZZ_API void SamplingCache_Resize(ozz_handle_t instance, int max_tracks)
{
  assert(instance);
  ozz::animation::SamplingCache* self = (ozz::animation::SamplingCache*)instance;
  self->Resize(max_tracks);
}

// SamplingJob

OZZ_API ozz_handle_t SamplingJob_Create()
{
  return new ozz::animation::SamplingJob();
}

OZZ_API void SamplingJob_Destroy(ozz_handle_t instance)
{
  assert(instance);
  ozz::animation::SamplingJob* self = (ozz::animation::SamplingJob*)instance;
  delete self;
}

OZZ_API void SamplingJob_SetAnimation(ozz_handle_t instance, ozz_handle_t animation)
{
  assert(instance);
  ozz::animation::SamplingJob* self = (ozz::animation::SamplingJob*)instance;

  assert(animation);
  ozz::animation::Animation* a = (ozz::animation::Animation*)animation;
  
  self->animation = a;
}

OZZ_API void SamplingJob_SetCache(ozz_handle_t instance, ozz_handle_t cache)
{
  assert(instance);
  ozz::animation::SamplingJob* self = (ozz::animation::SamplingJob*)instance;

  assert(cache);
  ozz::animation::SamplingCache* c = (ozz::animation::SamplingCache*)cache;
  
  self->cache = c;
}

OZZ_API void SamplingJob_SetRatio(ozz_handle_t instance, float ratio)
{
  assert(instance);
  ozz::animation::SamplingJob* self = (ozz::animation::SamplingJob*)instance;
  
  self->ratio = ratio;
}

OZZ_API void SamplingJob_SetOutput(ozz_handle_t instance, struct ozz_span_t span)
{
  assert(instance);
  ozz::animation::SamplingJob* self = (ozz::animation::SamplingJob*)instance;
  
  ozz::span<ozz::math::SoaTransform> s = ozz::span<ozz::math::SoaTransform>((ozz::math::SoaTransform*)span.data, span.size);
  
  self->output = s;
}

OZZ_API void SamplingJob_Run(ozz_handle_t instance)
{
  assert(instance);
  ozz::animation::SamplingJob* self = (ozz::animation::SamplingJob*)instance;
  
  self->Run();
}

// LocalToModelJob

OZZ_API ozz_handle_t LocalToModelJob_Create()
{
  return new ozz::animation::LocalToModelJob();
}

OZZ_API void LocalToModelJob_Destroy(ozz_handle_t instance)
{
  assert(instance);
  ozz::animation::LocalToModelJob* self = (ozz::animation::LocalToModelJob*)instance;
  delete self;
}

OZZ_API void LocalToModelJob_SetSkeleton(ozz_handle_t instance, ozz_handle_t skeleton)
{
  assert(instance);
  ozz::animation::LocalToModelJob* self = (ozz::animation::LocalToModelJob*)instance;

  assert(skeleton);
  ozz::animation::Skeleton* s = (ozz::animation::Skeleton*)skeleton;
  
  self->skeleton = s;
}

OZZ_API void LocalToModelJob_SetInput(ozz_handle_t instance, struct ozz_span_t span)
{
  assert(instance);
  ozz::animation::LocalToModelJob* self = (ozz::animation::LocalToModelJob*)instance;
  
  ozz::span<const ozz::math::SoaTransform> s = ozz::span<const ozz::math::SoaTransform>((const ozz::math::SoaTransform*)span.data, span.size);
  
  self->input = s;
}

OZZ_API void LocalToModelJob_SetOutput(ozz_handle_t instance, struct ozz_span_t span)
{
  assert(instance);
  ozz::animation::LocalToModelJob* self = (ozz::animation::LocalToModelJob*)instance;
  
  ozz::span<ozz::math::Float4x4> s = ozz::span<ozz::math::Float4x4>((ozz::math::Float4x4*)span.data, span.size);
  
  self->output = s;
}

OZZ_API void LocalToModelJob_Run(ozz_handle_t instance) 
{
  assert(instance);
  ozz::animation::LocalToModelJob* self = (ozz::animation::LocalToModelJob*)instance;
  
  self->Run();
}

// Stream

OZZ_API size_t Stream_Write(ozz_handle_t instance, const void* buffer, size_t size)
{
  assert(instance);
  ozz::io::Stream* self = (ozz::io::Stream*)instance;
  
  return self->Write(buffer, size);
}

OZZ_API int Stream_Seek(ozz_handle_t instance, int offset, int origin)
{
  assert(instance);
  ozz::io::Stream* self = (ozz::io::Stream*)instance;
  
  return self->Seek(offset, (ozz::io::Stream::Origin)origin);
}

// MemoryStream

OZZ_API ozz_handle_t MemoryStream_Create()
{
  return new ozz::io::MemoryStream();
}

OZZ_API void MemoryStream_Destroy(ozz_handle_t instance)
{
  assert(instance);
  ozz::io::MemoryStream* self = (ozz::io::MemoryStream*)instance;
  delete self;
}

// IArchive

OZZ_API ozz_handle_t IArchive_Create(ozz_handle_t stream)
{
  assert(stream);
  ozz::io::Stream* s = (ozz::io::Stream*)stream;

  return new ozz::io::IArchive(s);
}

OZZ_API void IArchive_Destroy(ozz_handle_t instance)
{
  assert(instance);
  ozz::io::IArchive* self = (ozz::io::IArchive*)instance;
  delete self;
}

OZZ_API int IArchive_TestTag_Skeleton(ozz_handle_t instance)
{
  assert(instance);
  ozz::io::IArchive* self = (ozz::io::IArchive*)instance;
  
  return self->TestTag<ozz::animation::Skeleton>();
}

OZZ_API void IArchive_Load_Skeleton(ozz_handle_t instance, ozz_handle_t skeleton)
{
  assert(instance);
  ozz::io::IArchive* self = (ozz::io::IArchive*)instance;

  assert(skeleton);
  ozz::animation::Skeleton* s = (ozz::animation::Skeleton*)skeleton;
  
  *self >> *s;
}

OZZ_API int IArchive_TestTag_Animation(ozz_handle_t instance)
{
  assert(instance);
  ozz::io::IArchive* self = (ozz::io::IArchive*)instance;
  
  return self->TestTag<ozz::animation::Animation>();
}

OZZ_API void IArchive_Load_Animation(ozz_handle_t instance, ozz_handle_t animation)
{
  assert(instance);
  ozz::io::IArchive* self = (ozz::io::IArchive*)instance;

  assert(animation);
  ozz::animation::Animation* a = (ozz::animation::Animation*)animation;
  
  *self >> *a;
}

OZZ_API int IArchive_TestTag_Mesh(ozz_handle_t instance)
{
  assert(instance);
  ozz::io::IArchive* self = (ozz::io::IArchive*)instance;
  
  return self->TestTag<ozz::sample::Mesh>();
}

OZZ_API void IArchive_Load_Mesh(ozz_handle_t instance, ozz_handle_t mesh)
{
  assert(instance);
  ozz::io::IArchive* self = (ozz::io::IArchive*)instance;

  assert(mesh);
  ozz::sample::Mesh* m = (ozz::sample::Mesh*)mesh;
  
  *self >> *m;
}
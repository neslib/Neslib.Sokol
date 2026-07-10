unit Neslib.Sokol.Glue;
{ The Sokol units should not depend on each other, but sometimes it's useful to
  have a set of helper functions as "glue" between two or more Sokol units.
  This is what this unit is for. }

{$INCLUDE 'Neslib.Sokol.inc'}

interface

uses
  Neslib.Sokol.App,
  Neslib.Sokol.Gfx;

type
  _TEnvironmentHelper = record helper for TEnvironment
  public
    procedure FromAppEnvironment;
  end;

type
  _TSwapchainHelper = record helper for TSwapchain
  public
    procedure FromAppSwapchain;
  end;

implementation

uses
  Neslib.Sokol.Api;

{ _TEnvironmentHelper }

procedure _TEnvironmentHelper.FromAppEnvironment;
begin
  var Env := _sglue_environment;
  _sg_environment_defaults(Self.Defaults^) := Env.defaults;
  _sg_metal_environment(Self.Metal^) := Env.metal;
  _sg_d3d11_environment(Self.D3D11^) := Env.d3d11;
  _sg_vulkan_environment(Self.Vulkan^) := Env.vulkan;
end;

{ _TSwapchainHelper }

procedure _TSwapchainHelper.FromAppSwapchain;
begin
  _sg_swapchain(Self) := _sglue_swapchain;
end;

end.

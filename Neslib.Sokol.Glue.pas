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
  _TApplicationHelper = class helper for TApplication
  {$REGION 'Internal Declarations'}
  private class var
    FContext: TContextDesc;
    FContextValid: Boolean;
  private
    class function GetContext: TContextDesc; inline; static;
    class procedure DoGetContext; static;
  {$REGION 'Internal Declarations'}
  public
    {  Returns a Gfx TContextDesc record for use with TApplication }
    class property Context: TContextDesc read GetContext;
  end;

implementation

uses
  Neslib.Sokol.Api;

type
  TApplicationAccess = class(TApplication);

{ _TApplicationHelper }

class procedure _TApplicationHelper.DoGetContext;
begin
  var Src := _sapp_sgcontext;
  FContext.ColorFormat := TPixelFormat(Src.color_format);
  FContext.DepthFormat := TPixelFormat(Src.depth_format);
  FContext.SampleCount := Src.sample_count;
  FContext.GL.ForceGles2 := Src.gl.force_gles2;
  FContext.Metal.Device := Src.metal.device;
  FContext.Metal.RenderpassDescriptorEvent := TApplicationAccess(TApplication.Instance).GetMetalRenderpassDescriptor;
  FContext.Metal.DrawableEvent := TApplicationAccess(TApplication.Instance).GetMetalDrawable;
  FContext.D3D11.Device := IInterface(Src.d3d11.device);
  FContext.D3D11.DeviceContext := IInterface(Src.d3d11.device_context);
  FContext.D3D11.RenderTargetViewEvent := TApplicationAccess(TApplication.Instance).GetD3D11RenderTargetView;
  FContext.D3D11.DepthStencilViewEvent := TApplicationAccess(TApplication.Instance).GetD3D11DepthStencilView;
end;

class function _TApplicationHelper.GetContext: TContextDesc;
begin
  if (not FContextValid) then
    DoGetContext;

  Result := FContext;
end;

end.

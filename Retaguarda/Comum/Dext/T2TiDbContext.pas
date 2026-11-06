unit T2TiDbContext;

interface

uses
  System.SysUtils,
  Dext.Entity,
  Dext.Entity.Core;

type
  /// Contexto Dext compartilhado pela Retaguarda.
  /// Entidades Dext nativas ser�o registradas em OnModelCreating conforme migra��o F3.
  TT2TiDbContext = class(TDbContext)
  protected
    procedure OnModelCreating(Builder: TModelBuilder); override;
  end;

implementation

procedure TT2TiDbContext.OnModelCreating(Builder: TModelBuilder);
begin
  inherited;
  // Entidades Dext (DbSet) entram aqui m�dulo a m�dulo � ver dext-orm-strategy.md
end;

end.

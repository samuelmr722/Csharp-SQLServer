USE [Estandares]
GO
/****** Object:  StoredProcedure [dbo].[Usp_DMD_ValidacionDatosDeudores]    Script Date: 06/05/2015 10:08:03 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Samuel Muñoz
-- Create date: 06/05/2015
-- Description:	Analisis calidad de datos Deudores cartera
-- llamado [Usp_DMD_ValidacionDatosDeudores]
-- =============================================

create PROCEDURE [dbo].[Usp_DMD_ValidacionDatosDeudores]

AS
BEGIN
 
SET NOCOUNT ON

--Eliminar funcion interlocutor para los codeudores
IF OBJECT_ID(N'tempdb..#temp', N'U') IS NOT NULL DROP TABLE #temp
select 
[Cliente],[Pais],[Nombre1],[Nombre2],[Población],[Region],[ConseBusqueda],[Calle],[TeléfonoFijo],[Tratamiento],[Latitud]
,[Longitud],[Ramo],[CreadoEl_General],[CreadoPor_General],[GrupoCuentas],[FechaExpedicionDocumento],[Nombre3],[Nombre4],[EstadoCliente]
,[Distrito],[EstratoCliente],[NumIdenFiscal],[TeléfonoMovil],[ZonaTransporte],[PersonaFisica],[ClaseImpuesto],[TipoNif],[Calle 2]
,[Calle 3],[Calle 4],[Calle 5],[Sociedad],[NumeroPersonal],[CreadoEl_Sociedad],[CreadoPor_Sociedad],[CuentaContable],[ViasPago]
,[CondicionPago],[GrupoTesoreria],[HistorialPago],[FechaNacimiento],[CIIU_Code],[OrganizaciónVentas],[CanalDistribucion],[Sector]
,[CreadoPor_Ventas],[CreadoEL_Ventas],[PeticionBorradoAreaVentas],[GrupoEstadisticaCliente],[BloqueoPedidoAreaVentas],[EsquemaCliente]
,[MailPlan],[ZonaVentas],[GrupoPrecios],[ListaPrecios],[BloqueoEntregaAreaVentas ],[PrioridadEntrega],[UltimaCampaña]
,[CondicionExpedicion],[BloqueoFacturaAreaVentas],[TratamientoPostFactura],[Moneda],[GrupoImputacion],[CondicionDePago]
,[CentroSuministrador],[GrupoVendedor],[OficinaVentas],[DeterminacionPrecio],[FunsionInterlocutor],[NumeroPersonal_ZD]
,[ClasificacionFiscal]
into #temp from DatosDeudoresValidar
Delete from #temp where FunsionInterlocutor <> 'ZD' and cliente in (select cliente from #temp where FunsionInterlocutor = 'ZD')
update #temp set FunsionInterlocutor = '', NumeroPersonal_ZD = '' where NumeroPersonal_ZD = '0'

IF OBJECT_ID(N'tempdb..#tempFinal', N'U') IS NOT NULL DROP TABLE #tempFinal
select * into #tempFinal from #temp
group by [Cliente],[Pais],[Nombre1],[Nombre2],[Población],[Region],[ConseBusqueda],[Calle],[TeléfonoFijo],[Tratamiento],[Latitud]
,[Longitud],[Ramo],[CreadoEl_General],[CreadoPor_General],[GrupoCuentas],[FechaExpedicionDocumento],[Nombre3],[Nombre4],[EstadoCliente]
,[Distrito],[EstratoCliente],[NumIdenFiscal],[TeléfonoMovil],[ZonaTransporte],[PersonaFisica],[ClaseImpuesto],[TipoNif],[Calle 2]
,[Calle 3],[Calle 4],[Calle 5],[Sociedad],[NumeroPersonal],[CreadoEl_Sociedad],[CreadoPor_Sociedad],[CuentaContable],[ViasPago]
,[CondicionPago],[GrupoTesoreria],[HistorialPago],[FechaNacimiento],[CIIU_Code],[OrganizaciónVentas],[CanalDistribucion],[Sector]
,[CreadoPor_Ventas],[CreadoEL_Ventas],[PeticionBorradoAreaVentas],[GrupoEstadisticaCliente],[BloqueoPedidoAreaVentas],[EsquemaCliente]
,[MailPlan],[ZonaVentas],[GrupoPrecios],[ListaPrecios],[BloqueoEntregaAreaVentas ],[PrioridadEntrega],[UltimaCampaña]
,[CondicionExpedicion],[BloqueoFacturaAreaVentas],[TratamientoPostFactura],[Moneda],[GrupoImputacion],[CondicionDePago]
,[CentroSuministrador],[GrupoVendedor],[OficinaVentas],[DeterminacionPrecio],[FunsionInterlocutor],[NumeroPersonal_ZD]
,[ClasificacionFiscal]
IF OBJECT_ID(N'tempdb..#temp', N'U') IS NOT NULL DROP TABLE #temp

--****************************************************************************************************************************************************************************
/* CONSULTAS DE TODOS LOS CRITERIOS DEFINIDOS Y ACORDADOS CON CARTERA */
--****************************************************************************************************************************************************************************
--*************************************************************Asesoras con directoras de zona incorrecta - INICIO
select Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],NumeroPersonal_ZD,ZonaVentas 
from #tempFinal 
where ZonaVentas in (select ZonaVentas from (select ZonaVentas,NumeroPersonal_ZD from #tempFinal group by ZonaVentas,NumeroPersonal_ZD) as a group by ZonaVentas having COUNT(ZonaVentas) > 1)

--*************************************************************Asesoras con directoras de zona incorrecta - FIN

--*************************************************************TelefonoFijo errados en longitud Y/O caracteres diferentes a numericos - INICIO
--Longitud direferntes de 10 y 7
select Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],TeléfonoFijo from #tempFinal where len(TeléfonoFijo) not in (10,7)  and TeléfonoFijo <> '' and TeléfonoFijo <> '0'
union
--Diferente de numero
select Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],TeléfonoFijo from #tempFinal where isnumeric(TeléfonoFijo) = 0 and TeléfonoFijo <> ''
--*************************************************************TelefonoFijo errados en longitud Y/O caracteres diferentes a numericos - FIN

--*************************************************************Telefonomovil errados en longitud Y/O caracteres diferentes a numericos - INICIO
--Longitud direferntes de 10 y 7
select Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],TeléfonoMovil from #tempFinal where len(TeléfonoMovil) not in (10,7)  and TeléfonoMovil <> '' and TeléfonoMovil <> '0'
union
--Diferente de numero
select Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],TeléfonoMovil from #tempFinal where isnumeric(TeléfonoMovil) = 0 and TeléfonoMovil <> ''
--*************************************************************Telefonomovil errados en longitud Y/O caracteres diferentes a numericos - FIN

--*************************************************************Deudor sin ClasificacionFiscal - INICIO
select Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],ClasificacionFiscal,GrupoCuentas,ZonaVentas 
from #tempFinal 
where ZonaVentas not in ('999999','') and ClasificacionFiscal <> '1'
--*************************************************************Deudor sin ClasificacionFiscal - FIN

--*************************************************************SIn grupo de imputacion o grupo imputacion errado - INICIO
select Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],GrupoImputacion,ZonaVentas,[BloqueoEntregaAreaVentas ],GrupoCuentas
from #tempFinal 
where ZonaVentas not in ('999999','000000','','00000') and GrupoImputacion <> '01'
group by Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],GrupoImputacion,ZonaVentas,[BloqueoEntregaAreaVentas ],GrupoCuentas
--*************************************************************SIn grupo de imputacion o grupo imputacion errado - FIN

--*************************************************************FechaExpidicion incorrecta - INICIO
select Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],FechaExpedicionDocumento,GrupoCuentas,ZonaVentas
from #tempFinal
where len(FechaExpedicionDocumento) <> 8 and GrupoCuentas in ('CARM','PCFK','EMPL') and ZonaVentas <> '999999'
--*************************************************************FechaExpidicion incorrecta - FIN

--*************************************************************FechaNacimiento incorrecta - INICIO
select Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],FechaNacimiento,GrupoCuentas,ZonaVentas
from #tempFinal
where len(FechaNacimiento) <> 8 and GrupoCuentas in ('CARM','PCFK','EMPL') and ZonaVentas <> '999999' and Sociedad = 'CO10'
--*************************************************************FechaNacimiento incorrecta - FIN

--*************************************************************Sin CondicionPago para las vistas Ventas y sociedad -INCIO
--*********CondicionPago ventas
select Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas], 'CondicionPagoVentas' CondicionDePago,GrupoCuentas,ZonaVentas
from #tempFinal
where GrupoCuentas in ('CARM','PCFK','EMPL') and CondicionDePago = ''  and ZonaVentas not in ('999999','')
union
--*********CondicionPago sociedad
select Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],'CondicionPagoSociedad' CondicionPago, GrupoCuentas ,ZonaVentas
from #tempFinal
where GrupoCuentas in ('CARM','PCFK','EMPL') and CondicionPago = ''   and ZonaVentas not in ('999999','')
--*************************************************************Sin CondicionPago para las vistas Ventas y sociedad -FIN

--*************************************************************Sin GrupoTesoreria o incorrecta - INICIO
select Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],GrupoTesoreria,GrupoCuentas,ZonaVentas
from #tempFinal
where GrupoTesoreria <> 'C1' and GrupoCuentas in ('CARM','PCFK') and ZonaVentas not in ('999999','000000') and Sociedad = 'CO10'
--*************************************************************Sin GrupoTesoreria o incorrecta - FIN

--*************************************************************(Cliente <> NumIdenFiscal) o (Cliente <> ConseBusqueda) o (ConseBusqueda <> NumIdenFiscal) - INICIO
select Cliente,NumIdenFiscal,ConseBusqueda,'Diferencias en CO12 y CO11' [Dif.Codi-ConseBus-NumFisca],[CreadoEL_Ventas],[CreadoPor_Ventas], ZonaVentas,[OrganizaciónVentas]
from #tempFinal
where ((Cliente <> NumIdenFiscal) or (Cliente <> ConseBusqueda) or (ConseBusqueda <> NumIdenFiscal)) and [OrganizaciónVentas] <> 'CO13'
union
select Cliente,NumIdenFiscal,ConseBusqueda,'Diferencias en CO13' [Dif.Codi-ConseBus-NumFisca],[CreadoEL_Ventas],[CreadoPor_Ventas], ZonaVentas,[OrganizaciónVentas]
from #tempFinal
where Cliente <> ConseBusqueda and [OrganizaciónVentas] = 'CO13'
--*************************************************************(Cliente <> NumIdenFiscal) o (Cliente <> ConseBusqueda) o (ConseBusqueda <> NumIdenFiscal) - FIN

--*************************************************************Validar el texto en los campos: Nombre1,Nombre2,Nombre3,Nombre4 - INICIO
--Minusculas
SELECT Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],Nombre1 as Nombre1,'' as Nombre2,'' as Nombre3,'' as Nombre4,'Tamaño' TipoDeValidacion from #tempFinal
where Nombre1 COLLATE Latin1_General_CS_AS <> upper(Nombre1) union

SELECT Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],'' as Nombre1,Nombre2 as Nombre2,'' as Nombre3,'' as Nombre4,'Tamaño' TipoDeValidacion from #tempFinal
where Nombre2 COLLATE Latin1_General_CS_AS <> upper(Nombre2) union

SELECT Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],'' as Nombre1,'' as Nombre2,Nombre3 as Nombre3,'' as Nombre4,'Tamaño' TipoDeValidacion from #tempFinal
where Nombre3 COLLATE Latin1_General_CS_AS <> upper(Nombre3) union

SELECT Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],'' as Nombre1,'' as Nombre2,'' as Nombre3,Nombre4 as Nombre4,'Tamaño' TipoDeValidacion from #tempFinal
where Nombre4 COLLATE Latin1_General_CS_AS <> upper(Nombre4) union

--Comas al final o al principio
select Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],'','',Nombre3,'','SobraUnaComa' from #tempFinal where left(Nombre3,1) = ',' or right(Nombre3,1) = ',' union

select Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],'','','',Nombre4,'SobraUnaComa' from #tempFinal where left(Nombre4,1) = ',' or right(Nombre4,1) = ',' union

--Caractertes diferentes a letras
select Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],Nombre1,'','','','CaracterDiferenteALetra' from #tempFinal where Nombre1 like '%[0-9]%' union

select Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],'',Nombre2,'','','CaracterDiferenteALetra' from #tempFinal where Nombre2 like '%[0-9]%' union

select Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],'','',Nombre3,'','CaracterDiferenteALetra' from #tempFinal where Nombre3 like '%[0-9]%' union

select Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],'','','',Nombre4,'CaracterDiferenteALetra' from #tempFinal where Nombre4 like '%[0-9]%'
--*************************************************************Validar el texto en los campos: Nombre1,Nombre2,Nombre3,Nombre4 - FIN

--*************************************************************Validar el texto en las direcciones: Calle, Calle2, Calle3, Calle4 - INICIO
--Minusculas
SELECT Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],Calle as Calle,'' as [Calle 2],'' as [Calle 3],'' as [Calle 4],'Tamaño' TipoDeValidacion from #tempFinal
where Calle COLLATE Latin1_General_CS_AS <> upper(Calle) and Calle not like '%o%' union

SELECT Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],'' as Calle,[Calle 2] as [Calle 2],'' as [Calle 3],'' as [Calle 4],'Tamaño' TipoDeValidacion from #tempFinal
where [Calle 2] COLLATE Latin1_General_CS_AS <> upper([Calle 2]) and Calle not like '%o%' union

SELECT Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],'' as Calle,'' as [Calle 2],[Calle 3] as [Calle 3],'' as [Calle 4],'Tamaño' TipoDeValidacion from #tempFinal
where [Calle 3] COLLATE Latin1_General_CS_AS <> upper([Calle 3]) and Calle not like '%o%' union

SELECT Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],'' as Calle,'' as [Calle 2],'' as [Calle 3],[Calle 4] as [Calle 4],'Tamaño' TipoDeValidacion from #tempFinal
where [Calle 4] COLLATE Latin1_General_CS_AS <> upper([Calle 4]) and Calle not like '%o%' union

--Longitud
select Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],Calle as Calle,[Calle 2] as [Calle 2],[Calle 3] as [Calle 3],'' as [Calle 4],'LongitudMuyPequeñaSinDatosEnlosDemasCalles' TipoDeValidacion
from #tempFinal where len(Calle) <=3 and [Calle 2] = '' and [Calle 3] = '' and [Calle 4] = '' union

--Caracteres
select Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],Calle as Calle,'' as [Calle 2],'' as [Calle 3],'' as [Calle 4],'CaracterNumeros' TipoDeValidacion
from #tempFinal where isnumeric(Calle) = 1 union

select Cliente,[CreadoEL_Ventas],[CreadoPor_Ventas],Calle as Calle,'' as [Calle 2],'' as [Calle 3],'' as [Calle 4],'CaracterEspecial' TipoDeValidacion
from #tempFinal where 
(Calle like '%[!]%') or (Calle like '%[&]%') or (Calle like '%[%]%') or
(Calle like '%[=]%') or (Calle like '%[{]%') or (Calle like '%[}]%') or 
(Calle like '%[*]%') or (Calle like '%[+]%') or (Calle like '%[?]%') or 
(Calle like '%[¡]%') or (Calle like '%[¿]%')
--*************************************************************Validar el texto en las direcciones: Calle, Calle2, Calle3, Calle4 - FIN

--*************************************************************Validar divisional VS Mail plan VS zona - INICIO
IF OBJECT_ID(N'calidad_datos..DatosDeudoresZonaMailPlanDivision', N'U') IS NOT NULL 
select s.[Cliente],s.CreadoEL_Ventas,s.CreadoPor_Ventas
,ltrim(rtrim(case when s.MailPlan <> p.MP then 'MP_Diferente' else '' end + ' ' + case when s.GrupoVendedor <> p.Division then 'Division_Diferente' else '' end)) [Dif.zona-MailPln-Division]
,s.OrganizaciónVentas,s.ZonaVentas,s.MailPlan MainPlan_Actual,p.MP MainPlan_Correcto,s.GrupoVendedor Division_Actual, p.Division Division_Correcta
from #tempFinal s inner join DatosDeudoresZonaMailPlanDivision p on s.ZonaVentas = p.Zona
where (s.MailPlan <> p.MP) or (s.GrupoVendedor <> p.Division)
ELSE 
select '','','','No Existe la tabla DatosDeudoresZonaMailPlanDivision | esta tabla es necesaria para la comparacion de Zona, Mail Plan y Division' [ERROR DE CAMPO]
--*************************************************************Validar divisional VS Mail plan VS zona - FIN

--*************************************************************Validar Ramo VS CIIU - INICIO
select Cliente,CreadoEl_General,CreadoPor_General,'Diferente' [RAMO = CIIU] ,Ramo,[CIIU_Code]
from #tempFinal
where [Sociedad] = 'CO10' and ZonaVentas not in ('999999','000000','','00000') and ([Ramo] <> [CIIU_Code] or Ramo <> '4771')
--*************************************************************Validar Ramo VS CIIU - FIN

--*************************************************************Cantidad Deudores Analizados - INICIO
declare @CantidadAnalizados numeric(18), @CantidadErrores numeric(18)
Select @CantidadAnalizados = COUNT(0) from #tempFinal
Select '','','',@CantidadAnalizados [Cantidad Deudores Analizados]
--*************************************************************Cantidad Deudores Analizados - FIN

IF OBJECT_ID(N'tempdb..#tempFinal', N'U') IS NOT NULL DROP TABLE #tempFinal

SET NOCOUNT OFF

end
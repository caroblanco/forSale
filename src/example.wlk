object inmobiliaria{
	const empleados = []
	var porcentaje
	
	method porcentaje() = porcentaje
	
	method darPorcentaje(nuevoP){
		porcentaje = nuevoP
	}
	
	method mejorEmpleadoSegun(criterio) = empleados.max({unE => criterio.evaluar(unE)}) 
	
}

class Cliente{
	const nombreCli
	
	method nombre() = nombreCli
	
	method coincideNombre(unN) = nombreCli == unN
}

/////////////////////////////////////////////////////////////////////////////////////////////////

object operacionesCerradas{
	method evaluar(unE) = unE.totalComisiones()
}

object cantCerradas{
	method evaluar(unE) = unE.cantCerradas()
}

object cantReservas{
	method evaluar(unE) = unE.cantReservas()
}

////////////////////////////////////////////////////////////////////////////////////////////////

class Empleado{
	const reservas = []
	const cerradas = []
	
	method cantCerradas() = cerradas.size() 
	method cantReservas() = reservas.size()
	
	method reservarA(operacion,cliente){
		operacion.reservar(cliente)
		reservas.add(operacion)
	}
	
	method concretarOp(operacion,cliente){
		operacion.concretar(cliente)
		cerradas.add(operacion)
	}
	
	method totalComisiones() = cerradas.sum({unaO => unaO.comision()})
	
	method tenerProblemaCon(otro) = self.cerramosEnMismaZona(otro) && self.concretoOpOpuesto(otro)
	
	method cerramosEnMismaZona(otro) =  self.zonasEnLasQOpero().any({unaZ => otro.operoEnZona(unaZ)})
	
	method concretoOpOpuesto(otro) = self.concretoOpReservadaPor(otro) || otro.concretoOpReservadaPor(self)
	
	method concretoOpReservadaPor(alguienMas) = cerradas.any({unaO => alguienMas.reservo(unaO)})
	
	method reservo(unaO) = reservas.contains(unaO)
	
	method operoEnZona(zona) = self.zonasEnLasQOpero().contains(zona)
	
	method zonasEnLasQOpero() = cerradas.map({unaO => unaO.inmueble().zona()})
}

/////////////////////////////////////////////////////////////////////////////////////////////////

class Operacion{
	const inmueble
	var estado
	
	method inmueble() = inmueble
	
	method reservar(cliente){
		self.confirmarVenta()
		estado.reservarPara(self,cliente)
	}
	
	method concretar(cliente){
		self.confirmarVenta()
		estado.concretarPara(self,cliente)
	}
	
	method cambiarEstado(nuevoE){
		estado = nuevoE
	}
	
	method confirmarVenta(){}
}

class Alquiler inherits Operacion{
	const meses
	
	method comision() = meses * inmueble.valor() / 50000
	
}

class Venta inherits Operacion{
	
	override method confirmarVenta(){
		inmueble.puedeVenderse()
	}
	
	method comision() = inmueble.valor() * inmobiliaria.porcentaje() / 100
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////

class Estado{
	method concretarPara(op,cliente){
		self.validarCierre(cliente)
		op.cambiarEstado(cerrada)
	}
	
	method validarCierre(cliente){}
	
	method reservarPara(op,cli)
}

object disponible inherits Estado{
	override method reservarPara(operacion,cliente){
		operacion.cambiarEstado(new Reservado(clienteRe = cliente))
	}
}

class Reservado inherits Estado{
	const clienteRe
	
	override method reservarPara(op,cli){
		self.error("YA ESTA RESERVADA")
	}
	
	override method validarCierre(cliente){
		if(cliente != clienteRe){
			self.error("NO SE PUEDE CONCRETAR")
		}
	}
}

object cerrada inherits Estado{
	override method reservarPara(op,cli){
		self.error("YA ESTA CERRADA")
	}
	
	override method validarCierre(cli){
		self.error("YA ESTA CERRADA")
	}
}
/////////////////////////////////////////////////////////////////////////////////////////////////

class Inmueble{
	const metros
	const ambientes
	const zona
	
	method valor() = zona.plus()
	
	method puedeVenderse(){}
}

class Casa inherits Inmueble{
	const costoPart
	
	override method valor() = super() + costoPart
}

class PH inherits Inmueble{
	override method valor() = super() + 14000*metros. max(500000)
}

class Depto inherits Inmueble{
	override method valor() = super() + 350000 * ambientes
}

class Local inherits Casa{
	var tipoLocal
	override method valor() = tipoLocal.valorFinal(super())
	
	override method puedeVenderse(){
		self.error("NO SE PUEDE VENDER UN LOCAL")
	}
}

object galpon{
	method valorFinal(base) = base / 2
}

object aLaCalle{
	var montoFijo
	
	method cambiarMF(nuevoM){
		montoFijo = nuevoM
	}
	
	method valorFinal(base) = base + montoFijo
}

class Zona{
	var valor
	method plus() = valor
}


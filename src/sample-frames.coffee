simpleFrames = []
createSingleRuleFrame = (name, severity, requiredSlots, ruleProcedure, suggestedCorrection = "No hay sugerencias para este estado de proyecto") ->
  simpleFrames.push(
    (new Frame
        name:     name
        suggestedCorrection: suggestedCorrection
        severity: severity
    ).addRule requiredSlots, ruleProcedure
  )

SEVERIDAD =
  GRAVE: 'severidad-grave'
  MEDIA: 'severidad-media'

ACUERDO =
  FIXED_PRICE: 'fp'
  CPFF:        'cpff'
  TIME_MAT:    'tm'
  MANPOWER:    'mp'

createSingleRuleFrame 'Presupuesto superado', SEVERIDAD.GRAVE,
    ['totalBudget', 'executedBudget', 'projectType'],
    (proj) ->
      proj.budgetExceeded() and proj.projectType in [ACUERDO.FIXED_PRICE, ACUERDO.CPFF],
    'Se debe hablar con el cliente y ver si esta dispuesto a aportar mas dinero al proyecto
    para terminar toda la funcionalidad requerida. Si es asi se debe continuar, sino 
    se debe redondear y entregar el proyecto con las funcionalidades completadas hasta 
    el momento.'
    
createSingleRuleFrame 'Costos subestimados', SEVERIDAD.GRAVE,
    [
      'totalBudget'
      'executedBudget'
      'commitedFunctionality'
      'deliveredFunctionality'
      'projectType'
    ],
    (proj) ->
      spendingRatio = proj.executedBudget / proj.totalBudget
      deliveryRatio = proj.deliveredFunctionality / proj.commitedFunctionality
      spendingRatio > deliveryRatio and proj.projectType in [ACUERDO.FIXED_PRICE, ACUERDO.TIME_MAT],
    'Analisar si es viable extender el presupuesto del proyecto y renegociar el mismo de 
    ser necesario ya que con el ritmo actual el proyecto va a necesitar mas dinero del
    planificado.'

createSingleRuleFrame 'Costos subestimados', SEVERIDAD.MEDIA,
    [
      'totalBudget'
      'executedBudget'
      'commitedFunctionality'
      'deliveredFunctionality'
      'projectType'
    ],
    (proj) ->
      spendingRatio = proj.executedBudget / proj.totalBudget
      deliveryRatio = proj.deliveredFunctionality / proj.commitedFunctionality
      spendingRatio > deliveryRatio and proj.projectType is ACUERDO.CPFF ,
    'Analisar si es viable extender el presupuesto del proyecto y renegociar el mismo de 
    ser necesario ya que con el ritmo actual el proyecto va a necesitar mas dinero del
    planificado.'


createSingleRuleFrame 'Calendario atrasado', SEVERIDAD.GRAVE,
    [
      'elapsedTime'
      'estimatedTime'
      'commitedFunctionality'
      'deliveredFunctionality'
      'projectType'
    ],
    (proj) ->
      calendarRatio = proj.elapsedTime / proj.estimatedTime
      deliveryRatio = proj.deliveredFunctionality / proj.commitedFunctionality
      calendarRatio > deliveryRatio and proj.projectType is ACUERDO.CPFF,
    'Si todavia falta bastante tiempo para finalizar el proyecto y si se dispone de mas
    presupuesto, agregar mas recursos al proyecto para poder corregir el desvio en el tiempo.
     Si no hay mucho tiempo, otra posibilidad es ver si los recursos actuales 
    pueden trabajar extra en el proyecto ( lo cual deviene en mas presupuesto). Esto siempre
    y cuando prime la fecha de entrega (y esta sea rigurosa) sobre el presupuesto. Si esto
    no es posible hay que analizar la posibilidad de terminar el proyecto.'

createSingleRuleFrame 'Calendario atrasado', SEVERIDAD.MEDIA,
    [
      'elapsedTime'
      'estimatedTime'
      'commitedFunctionality'
      'deliveredFunctionality'
      'projectType'
    ],
    (proj) ->
      calendarRatio = proj.elapsedTime / proj.estimatedTime
      deliveryRatio = proj.deliveredFunctionality / proj.commitedFunctionality
      calendarRatio > deliveryRatio and proj.projectType in [ACUERDO.MANPOWER, ACUERDO.TIME_MAT],
    'Si todavia falta bastante tiempo para finalizar el proyecto y si se dispone de mas
    presupuesto, agregar mas recursos al proyecto para poder corregir el desvio en el tiempo.
     Si no hay mucho tiempo, otra posibilidad es ver si los recursos actuales 
    pueden trabajar extra en el proyecto ( lo cual deviene en mas presupuesto). Esto siempre
    y cuando prime la fecha de entrega (y esta sea rigurosa) sobre el presupuesto. Si esto
    no es posible hay que analizar la posibilidad de terminar el proyecto.'


createSingleRuleFrame 'Esfuerzo subestimado', SEVERIDAD.GRAVE,
    [
      'investedEffort'
      'estimatedEffort'
      'commitedFunctionality'
      'deliveredFunctionality'
    ],
    (proj) ->
      effortRatio = proj.investedEffort / proj.estimatedEffort
      deliveryRatio = proj.deliveredFunctionality / proj.commitedFunctionality
      effortRatio > deliveryRatio,
    'Una vez que el proyecto ya se encuentra en curso, la incertidumbre es mas baja.
    Si se ha subestimado el proyecto se debe volver a estimar el proyecto y con una
    estimacion mas precisa renegociar el proyecto con el cliente.'

createSingleRuleFrame 'Gestion de cambios deficiente', SEVERIDAD.GRAVE,
    [
      'commitedFunctionality'
      'deliveredFunctionality'
      'projectType'
    ],
    (proj) ->
      proj.deliveredFunctionality > 1.1 * proj.commitedFunctionality and
          proj.projectType in [ACUERDO.FIXED_PRICE, ACUERDO.CPFF],
    'El proyecto esta incluyendo mas funcionalidades de las comprometidas en un primer
    momento. Se debe ser mas estricto con el plan de proyecto, a menos que el cliente 
    este dispuesto a incrementar el presupuesto y que se posea recursos para
    estirar el mismo.'

createSingleRuleFrame 'Gestion de cambios deficiente', SEVERIDAD.MEDIA,
    [
      'commitedFunctionality'
      'deliveredFunctionality'
      'projectType'
    ],
    (proj) ->
      proj.deliveredFunctionality > 1.1 * proj.commitedFunctionality and
          proj.projectType is ACUERDO.TIME_MAT,
    'El proyecto esta incluyendo mas funcionalidades de las comprometidas en un primer
    momento. Se debe ser mas estricto con el plan de proyecto, a menos que el cliente 
    este dispuesto a incrementar el presupuesto y que se posea recursos para
    estirar el mismo.'

createSingleRuleFrame 'Calendario excedente', SEVERIDAD.MEDIA,
    [
      'elapsedTime'
      'estimatedTime'
      'commitedFunctionality'
      'deliveredFunctionality'
    ],
    (proj) ->
      allDelivered = proj.deliveredFunctionality >= proj.commitedFunctionality
      early = proj.estimatedTime > 1.1 * proj.elapsedTime
      allDelivered and early,
    'En este caso a el proyecto le sobra tiempo. Si bien no es bueno que se haya 
    sobreestimado la duracion del mismo, no es razon para alarmarse.'

createSingleRuleFrame 'Esfuerzo sobreestimado', SEVERIDAD.ALTO,
    [
      'investedEffort'
      'estimatedEffort'
      'commitedFunctionality'
      'deliveredFunctionality'
      'projectType'
    ],
    (proj) ->
      allDelivered = proj.deliveredFunctionality >= proj.commitedFunctionality
      overestimated = proj.estimatedEffort > 1.1 * proj.investedEffort
      allDelivered and overestimated and proj.projectType is ACUERDO.MANPOWER,
    'En este caso al proyecto le sobra tiempo y el cliente paga por tiempo, por lo 
    que se podria tener el caso de tener gente osciosa. No hay solucion para esto.'

createSingleRuleFrame 'Esfuerzo sobreestimado', SEVERIDAD.MEDIA,
    [
      'investedEffort'
      'estimatedEffort'
      'commitedFunctionality'
      'deliveredFunctionality'
      'projectType'
    ],
    (proj) ->
      allDelivered = proj.deliveredFunctionality >= proj.commitedFunctionality
      overestimated = proj.estimatedEffort > 1.1 * proj.investedEffort
      allDelivered and overestimated and proj.projectType is ACUERDO.FIXED_PRICE,
    'En este caso al proyecto le sobra tiempo aunque el proyecto se paga como si 
    hubiera transcurrido todo el tiempo. No habria problema en principio.'


compositeFrames = []
compositeFrames.push new CompositeFrame
  name: 'Proyecto al horno'
  suggestedCorrection: 'Yo que usted empiezo a correr...'
  requiredFrames: ['Presupuesto superado', 'Gestion de cambios deficiente']

# To export for the browser
_window = this
exportName = (name, value) ->
  return unless _.isString(name) and not _.isEmpty name
  if module? # Export as node module
    module.exports[name] = value
  _window[name] = value

exportName 'simpleFrames', simpleFrames
exportName 'compositeFrames', compositeFrames

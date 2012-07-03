// Generated by CoffeeScript 1.3.3
var compositeFrames, createSingleRuleFrame, simpleFrames;

simpleFrames = [];

createSingleRuleFrame = function(name, requiredSlots, ruleProcedure) {
  return simpleFrames.push((new Frame({
    name: name
  })).addRule(requiredSlots, ruleProcedure));
};

createSingleRuleFrame('Presupuesto superado', ['totalBudget', 'executedBudget'], function(proj) {
  return proj.budgetExceeded();
});

createSingleRuleFrame('Costos subestimados', ['totalBudget', 'executedBudget', 'commitedFunctionality', 'deliveredFunctionality'], function(proj) {
  var deliveryRatio, spendingRatio;
  spendingRatio = proj.executedBudget / proj.totalBudget;
  deliveryRatio = proj.deliveredFunctionality / proj.commitedFunctionality;
  return spendingRatio > deliveryRatio;
});

createSingleRuleFrame('Calendario atrasado', ['elapsedTime', 'estimatedTime', 'commitedFunctionality', 'deliveredFunctionality'], function(proj) {
  var calendarRatio, deliveryRatio;
  calendarRatio = proj.elapsedTime / proj.estimatedTime;
  deliveryRatio = proj.deliveredFunctionality / proj.commitedFunctionality;
  return calendarRatio > deliveryRatio;
});

createSingleRuleFrame('Esfuerzo subestimado', ['investedEffort', 'estimatedEffort', 'commitedFunctionality', 'deliveredFunctionality'], function(proj) {
  var deliveryRatio, effortRatio;
  effortRatio = proj.investedEffort / proj.estimatedEffort;
  deliveryRatio = proj.deliveredFunctionality / proj.commitedFunctionality;
  return effortRatio > deliveryRatio;
});

createSingleRuleFrame('Gestion de cambios deficiente', ['commitedFunctionality', 'deliveredFunctionality'], function(proj) {
  return proj.deliveredFunctionality > 1.1 * proj.commitedFunctionality;
});

createSingleRuleFrame('Calendario excedente', ['elapsedTime', 'estimatedTime', 'commitedFunctionality', 'deliveredFunctionality'], function(proj) {
  var allDelivered, early;
  allDelivered = proj.deliveredFunctionality >= proj.commitedFunctionality;
  early = proj.estimatedTime > 1.1 * proj.elapsedTime;
  return allDelivered && early;
});

createSingleRuleFrame('Esfuerzo sobreestimado', ['investedEffort', 'estimatedEffort', 'commitedFunctionality', 'deliveredFunctionality'], function(proj) {
  var allDelivered, overestimated;
  allDelivered = proj.deliveredFunctionality >= proj.commitedFunctionality;
  overestimated = proj.estimatedEffort > 1.1 * proj.investedEffort;
  return allDelivered && overestimated;
});

compositeFrames = [];

compositeFrames.push(new CompositeFrame({
  name: 'Proyecto al horno',
  requiredFrames: ['Presupuesto superado', 'Gestion de cambios deficiente']
}));
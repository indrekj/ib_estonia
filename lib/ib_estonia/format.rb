def Format(value)
  if value.is_a?(BigDecimal)
    sprintf("%.2f", value.round(2))
  else
    value
  end
end

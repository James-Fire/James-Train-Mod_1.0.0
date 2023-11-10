data:extend(
{
  {
    type = "bool-setting",
    name = "train-tiers",
    setting_type = "startup",
    default_value = false,
	order = "a-0",
  },
  {
    type = "bool-setting",
    name = "train-car-tiers",
    setting_type = "startup",
    default_value = false,
	order = "a-1",
  },
  {
    type = "bool-setting",
    name = "weighty-trains",
    setting_type = "startup",
    default_value = false,
	order = "b-0",
  },
  {
    type = "double-setting",
    name = "weighty-trains-factor",
    setting_type = "startup",
	default_value = 5,
	minimum_value = 1,
	order = "b-1",
  },
  {
    type = "bool-setting",
    name = "variable-weighty-trains",
    setting_type = "startup",
    default_value = false,
	order = "b-2",
  },
  {
    type = "bool-setting",
    name = "powered-rails",
    setting_type = "startup",
    default_value = false,
	order = "c-0",
  },
  {
    type = "bool-setting",
    name = "electric-trains",
    setting_type = "startup",
    default_value = false,
	order = "c-1",
  },
  {
    type = "bool-setting",
    name = "electric-train-cars",
    setting_type = "startup",
    default_value = false,
	order = "c-2",
  },
  {
    type = "bool-setting",
    name = "electric-train-upgrade",
    setting_type = "startup",
    default_value = false,
	order = "c-3",
  },
  --[[{
    type = "bool-setting",
    name = "diesel-trains",
    setting_type = "startup",
    default_value = false,
	order = "d-0",
  },
  {
    type = "bool-setting",
    name = "steam-trains",
    setting_type = "startup",
    default_value = false,
	order = "e-0",
  },
  {
    type = "bool-setting",
    name = "tender-trains",
    setting_type = "startup",
    default_value = false,
	order = "f-0",
  },]]
 })
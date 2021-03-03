variable "region"{ 
    default = "us-east-1"
    description = "Região"
 }

 variable "access_key"{ 
    default = "secret"
}

 variable "secret_key"{ 
    default = "secret"
 }

 variable "cidr_block"{ 
    default = "192.168.0.0/16"
 }

 variable "private_a_cidr_block" {
     default = "192.168.6.0/23"
 }

variable "engine_version" {
  default     = "12.5"
  type        = string
  description = "Engine Version do DB"
}

variable "parameter_group" {
  default     = "default.postgres12"
  type        = string
  description = "Parameter Group do DB"
}

variable "monitoring_interval" {
  default     = 30
  type        = number
  description = "Intervalo em segundos, nos quais o Enhanced Monitoring coleta métricas "
}

variable "deletion_protection" {
  default     = false
  type        = bool
  description = "Flag que protege o DB contra o delete"
}

variable "cloudwatch_logs_exports" {
  default     = ["postgresql", "upgrade"]
  type        = list
  description = "Lista dos logs do CloudWatch Logs"
}

variable "alarm_cpu_threshold" {
  default     = 75
  type        = number
  description = "Threshold do Alarme de CPU como porcentagem"
}

variable "alarm_free_disk_threshold" {
  # 5GB
  default     = 5000000000
  type        = number
  description = "Threshold do alarme de disco livre em bytes"
}

variable "alarm_free_memory_threshold" {
  # 128MB
  default     = 128000000
  type        = number
  description = "Threshold do alarme de memória livre em bytes"
}

variable "ami" {
   default = "ami-0915bcb5fa77e4892"
   
}

variable "instance_type" {
   default = "t2.micro"

}

variable "key_pair" {
   default = "sergio"

}

-- Oficina: criação em MySQL 8.0.16+. Execute em um esquema novo.
-- Não remove tabelas ou dados existentes.
CREATE DATABASE IF NOT EXISTS oficina CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE oficina;

CREATE TABLE Cliente (
 idCliente INT AUTO_INCREMENT PRIMARY KEY,
 Nome VARCHAR(100) NOT NULL,
 CPF CHAR(11) NOT NULL UNIQUE,
 Telefone VARCHAR(20),
 Email VARCHAR(120),
 Endereco VARCHAR(200),
 CONSTRAINT chk_cliente_nome CHECK (CHAR_LENGTH(TRIM(Nome)) > 0),
 CONSTRAINT chk_cliente_cpf CHECK (CHAR_LENGTH(TRIM(CPF)) = 11)
) ENGINE=InnoDB;

CREATE TABLE Veiculo (
 idVeiculo INT AUTO_INCREMENT PRIMARY KEY,
 Cliente_idCliente INT NOT NULL,
 Placa CHAR(7) NOT NULL UNIQUE,
 Marca VARCHAR(40) NOT NULL,
 Modelo VARCHAR(60) NOT NULL,
 Ano SMALLINT NOT NULL,
 CONSTRAINT chk_veiculo_placa CHECK (CHAR_LENGTH(TRIM(Placa)) = 7),
 CONSTRAINT chk_veiculo_ano CHECK (Ano BETWEEN 1886 AND 2100),
 CONSTRAINT fk_veiculo_cliente FOREIGN KEY (Cliente_idCliente) REFERENCES Cliente(idCliente)
) ENGINE=InnoDB;

CREATE TABLE Equipe (
 idEquipe INT AUTO_INCREMENT PRIMARY KEY,
 Nome VARCHAR(80) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE Mecanico (
 idMecanico INT AUTO_INCREMENT PRIMARY KEY,
 Nome VARCHAR(100) NOT NULL,
 Especialidade VARCHAR(80) NOT NULL,
 Endereco VARCHAR(200)
) ENGINE=InnoDB;

CREATE TABLE MecanicoEquipe (
 Equipe_idEquipe INT NOT NULL,
 Mecanico_idMecanico INT NOT NULL,
 PRIMARY KEY (Equipe_idEquipe, Mecanico_idMecanico),
 CONSTRAINT fk_em_equipe FOREIGN KEY (Equipe_idEquipe) REFERENCES Equipe(idEquipe),
 CONSTRAINT fk_em_mecanico FOREIGN KEY (Mecanico_idMecanico) REFERENCES Mecanico(idMecanico)
) ENGINE=InnoDB;

CREATE TABLE OrdemServico (
 idOrdemServico INT AUTO_INCREMENT PRIMARY KEY,
 Veiculo_idVeiculo INT NOT NULL,
 Equipe_idEquipe INT NOT NULL,
 DataEmissao DATE NOT NULL,
 DataPrevista DATE NOT NULL,
 DataConclusao DATE,
 Autorizacao ENUM('Pendente','Autorizada','Recusada') NOT NULL DEFAULT 'Pendente',
 DataAutorizacao DATE,
 Status ENUM('Aberta','Em execucao','Concluida','Cancelada') NOT NULL DEFAULT 'Aberta',
 Quilometragem INT NOT NULL,
 RelatoCliente VARCHAR(500) NOT NULL,
 CONSTRAINT chk_os_km CHECK (Quilometragem >= 0),
 CONSTRAINT chk_os_prazo CHECK (DataPrevista >= DataEmissao),
 CONSTRAINT chk_os_autorizacao CHECK (
   (Autorizacao = 'Autorizada' AND DataAutorizacao IS NOT NULL AND DataAutorizacao >= DataEmissao)
   OR (Autorizacao IN ('Pendente','Recusada') AND DataAutorizacao IS NULL)),
 CONSTRAINT chk_os_execucao CHECK (Status NOT IN ('Em execucao','Concluida') OR Autorizacao = 'Autorizada'),
 CONSTRAINT chk_os_recusa CHECK (Autorizacao <> 'Recusada' OR Status = 'Cancelada'),
 CONSTRAINT chk_os_conclusao CHECK (
   (Status = 'Concluida' AND DataConclusao IS NOT NULL AND DataConclusao >= DataEmissao
    AND DataConclusao >= DataAutorizacao)
   OR (Status <> 'Concluida' AND DataConclusao IS NULL)),
 CONSTRAINT fk_os_veiculo FOREIGN KEY (Veiculo_idVeiculo) REFERENCES Veiculo(idVeiculo),
 CONSTRAINT fk_os_equipe FOREIGN KEY (Equipe_idEquipe) REFERENCES Equipe(idEquipe)
) ENGINE=InnoDB;

CREATE TABLE Servico (
 idServico INT AUTO_INCREMENT PRIMARY KEY,
 Descricao VARCHAR(120) NOT NULL UNIQUE,
 ValorReferencia DECIMAL(10,2) NOT NULL,
 CONSTRAINT chk_servico_valor CHECK (ValorReferencia >= 0)
) ENGINE=InnoDB;

CREATE TABLE ItemServico (
 OrdemServico_idOrdemServico INT NOT NULL,
 Servico_idServico INT NOT NULL,
 Quantidade DECIMAL(8,2) NOT NULL,
 ValorUnitario DECIMAL(10,2) NOT NULL,
 PRIMARY KEY (OrdemServico_idOrdemServico, Servico_idServico),
 CONSTRAINT chk_oss_quantidade CHECK (Quantidade > 0),
 CONSTRAINT chk_oss_valor CHECK (ValorUnitario >= 0),
 CONSTRAINT fk_oss_os FOREIGN KEY (OrdemServico_idOrdemServico) REFERENCES OrdemServico(idOrdemServico),
 CONSTRAINT fk_oss_servico FOREIGN KEY (Servico_idServico) REFERENCES Servico(idServico)
) ENGINE=InnoDB;

CREATE TABLE Peca (
 idPeca INT AUTO_INCREMENT PRIMARY KEY,
 Codigo VARCHAR(30) NOT NULL UNIQUE,
 Descricao VARCHAR(120) NOT NULL,
 ValorReferencia DECIMAL(10,2) NOT NULL,
 CONSTRAINT chk_peca_valor CHECK (ValorReferencia >= 0)
) ENGINE=InnoDB;

CREATE TABLE ItemPeca (
 OrdemServico_idOrdemServico INT NOT NULL,
 Peca_idPeca INT NOT NULL,
 Quantidade INT NOT NULL,
 ValorUnitario DECIMAL(10,2) NOT NULL,
 PRIMARY KEY (OrdemServico_idOrdemServico, Peca_idPeca),
 CONSTRAINT chk_osp_quantidade CHECK (Quantidade > 0),
 CONSTRAINT chk_osp_valor CHECK (ValorUnitario >= 0),
 CONSTRAINT fk_osp_os FOREIGN KEY (OrdemServico_idOrdemServico) REFERENCES OrdemServico(idOrdemServico),
 CONSTRAINT fk_osp_peca FOREIGN KEY (Peca_idPeca) REFERENCES Peca(idPeca)
) ENGINE=InnoDB;

-- Agregar separadamente evita duplicar valores ao unir peças e serviços.
CREATE VIEW vw_TotalOrdemServico AS
SELECT os.idOrdemServico,
 COALESCE(s.TotalServicos, 0) AS TotalServicos,
 COALESCE(p.TotalPecas, 0) AS TotalPecas,
 COALESCE(s.TotalServicos, 0) + COALESCE(p.TotalPecas, 0) AS TotalOrdem
FROM OrdemServico os
LEFT JOIN (
 SELECT OrdemServico_idOrdemServico, SUM(Quantidade * ValorUnitario) AS TotalServicos
 FROM ItemServico GROUP BY OrdemServico_idOrdemServico
) s ON s.OrdemServico_idOrdemServico = os.idOrdemServico
LEFT JOIN (
 SELECT OrdemServico_idOrdemServico, SUM(Quantidade * ValorUnitario) AS TotalPecas
 FROM ItemPeca GROUP BY OrdemServico_idOrdemServico
) p ON p.OrdemServico_idOrdemServico = os.idOrdemServico;

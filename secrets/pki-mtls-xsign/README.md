---
tags:
  - docker
  - hashicorp
  - hcp-vault
  - vault
  - hcp-terraform
  - terraform
  - pki
  - mtls
  - tech
alias:
  - HashiCorp Vault: Secrets / PKI / mTLS Cross-Sign
---

---
# HashiCorp Vault: Secrets / PKI / mTLS Cross-Sign

PKI mTLS Cross-Sign Pattern

## Introduction

#### Contents

```shell
.
├── xsign-app-based-roots
│   ├── data
│   │   ├── ..
│   │   └── .
│   ├── workspace
│   │   ├── ..
│   │   └── .
│   ├── Makefile
│   └── README.md
├── xsign-service-based-roots
│   ├── data
│   │   ├── ..
│   │   └── .
│   ├── workspace
│   │   ├── ..
│   │   └── .
│   ├── Makefile
│   └── README.md
├── Makefile
└── README.md
```

#### Cast of Characters

- `PCF` == Bob
- `SMF` == Alice
- `AMF` == Carol
- `NEF` == Charlie

#### Interactions

`NEF` >> **N29** >> `SMF` >> **N7** >> `PCF`

`SMF` << **N11** << `AMF` >> **N15** >> `PCF`

- **N29** / `NEF` >> `SMF`
- **N7**  / `SMF` >> `PCF`
- **N11** / `AMF` >> `SMF`
- **N15** / `AMF` >> `PCF`

#### Service Based Architecture Flows

###### Basic Flow (Alice & Bob):

- **N7**  / `SMF` >> `PCF` SBA Flow
  ```mermaid
  graph LR
    SMF -- N7 --> PCF;
  ```


- **N7**  / `SMF` >> `PCF` PKI Trust Chain:
  ```mermaid
  graph LR 
    SMF-ROOT==N7-CSR==>PCF-ROOT==N7-IMPORT==>SMF-INT-N7


    subgraph SMF
    SMF-ROOT((SMF-ROOT))-->SMF-INT-N7-->SMF-N7-Leaf>SMF-N7-Leaf]
    SMF-ROOT((SMF-ROOT))-->SMF-INT-->SMF-Server-Leaf>SMF-Server-Leaf]
    end

    subgraph PCF
    PCF-ROOT((PCF-ROOT))-->PCF-INT-->PCF-Server-Leaf>PCF-Server-Leaf]
    end

  ```
###### Adding more Characters (Carol, Charlie, Alice, & Bob):

```mermaid
graph LR
  AMF -- N11 --> SMF;
  AMF -- N15 --> PCF;
  SMF -- N7 --> PCF;
  NEF -- N29 --> SMF;
```

#### PKI Cross-Sign Flows: Application Based Roots

CA Root per Application: Each Application (CNF) in this case will get it's own CA Root but the caveat here is that once a CA Root Cross-Signs, the `TRUSTED` PKI Chain then will be able to access resources Signed by that [*Signing*] Root.

For example, If the `PCF` Cross-Signs the CSR from the `AMF` for the `N15` interaction in the diagram above, the `AMF` will be able to access the `PCF` on both the `N15` ***AND*** `N7` Service APIs Signed by the `PCF`'s CA Root & Intermediate.

```mermaid
graph LR 
  SMF-ROOT==N7-CSR==>PCF-ROOT==N7-IMPORT==>SMF-INT-N7
  AMF-ROOT==N15-CSR==>PCF-ROOT==N15-IMPORT==>AMF-INT-N15
  AMF-ROOT==N11-CSR==>SMF-ROOT==N11-IMPORT==>AMF-INT-N11
  NEF-ROOT==N29-CSR==>SMF-ROOT==N29-IMPORT==>NEF-INT-N29

  subgraph SMF
  SMF-ROOT((SMF-ROOT))-->SMF-INT-N7-->SMF-N7-Leaf>SMF-N7-Leaf]
  SMF-ROOT((SMF-ROOT))-->SMF-INT-->SMF-Server-Leaf>SMF-Server-Leaf]
  end

  subgraph AMF
  AMF-ROOT((AMF-ROOT))-->AMF-INT-N15-->AMF-N15-Leaf>AMF-N15-Leaf]
  AMF-ROOT((AMF-ROOT))-->AMF-INT-->AMF-Server-Leaf>AMF-Server-Leaf]
  AMF-ROOT((AMF-ROOT))-->AMF-INT-N11-->AMF-N11-Leaf>AMF-N11-Leaf]
  end

  subgraph NEF
  NEF-ROOT((NEF-ROOT))-->NEF-INT-N29-->NEF-29-Leaf>NEF-N29-Leaf]
  NEF-ROOT((NEF-ROOT))-->NEF-INT-->NEF-Server-Leaf>NEF-Server-Leaf]
  end

  subgraph PCF
  PCF-ROOT((PCF-ROOT))-->PCF-INT-->PCF-Server-Leaf>PCF-Server-Leaf]
  end

```

#### PKI Cross-Sign Flows: Service Based Roots

CA Root per N-Interface Service: Better Access Controls for each Service


```mermaid
graph LR 
  SMF-ROOT==N7-CSR==>PCF-ROOT-N7==N7-IMPORT==>SMF-INT-N7
  AMF-ROOT==N11-CSR==>SMF-ROOT-N11==N11-IMPORT==>AMF-INT-N11
  AMF-ROOT==N15-CSR==>PCF-ROOT-N15==N15-IMPORT==>AMF-INT-N15
  NEF-ROOT==N29-CSR==>SMF-ROOT-N29==N29-IMPORT==>NEF-INT-N29

  subgraph PCF
  PCF-ROOT-N7((PCF-ROOT-N7))-->PCF-INT-N7-->PCF-N7-Server-Leaf>PCF-N7-Server-Leaf]
  PCF-ROOT-N15((PCF-ROOT-N15))-->PCF-INT-N15-->PCF-N15-Server-Leaf>PCF-N15-Server-Leaf]
  PCF-ROOT((PCF-ROOT))-->PCF-INT-->PCF-Server-Leaf>PCF-Server-Leaf]
  end

  subgraph AMF
  AMF-ROOT((AMF-ROOT))-->AMF-INT-->AMF-Server-Leaf>AMF-Server-Leaf]
  AMF-ROOT-->AMF-INT-N11-->AMF-N11-Client-Leaf>AMF-N11-Client-Leaf]
  AMF-ROOT-->AMF-INT-N15-->AMF-N15-Client-Leaf>AMF-N15-Client-Leaf]
  end

  subgraph SMF
  SMF-ROOT-N11((SMF-ROOT-N11))-->SMF-INT-N11-->SMF-N11-Server-Leaf>SMF-N11-Server-Leaf]
  SMF-ROOT-N29((SMF-ROOT-N29))-->SMF-INT-N29-->SMF-N29-Server-Leaf>SMF-N29-Server-Leaf]
  SMF-ROOT((SMF-ROOT))-->SMF-INT-N7-->SMF-N7-Client-Leaf>SMF-N7-Client-Leaf]
  end

  subgraph NEF
  NEF-ROOT((NEF-ROOT))-->NEF-INT-->NEF-Server-Leaf>NEF-Server-Leaf]
  NEF-ROOT-->NEF-INT-N29-->NEF-29-Client-Leaf>NEF-N29-Client-Leaf]
  end

```

#### 5G Packet Core SBA

```mermaid
graph LR

  subgraph 5G
    UE -- N1 --> AMF;
    UE --- gNB;
    gNB -- N2 --> AMF;
    gNB -- N3 --> UPF;
    UPF -- N6 --> DN;
    UPF -- N9 --> UPF;
    UPF -- N19 --> UPF-PSA;
    UPF -- N18 --> UDSF;
  end

  AMF -- N14 --> AMF;
  AMF -- N12 --> AUSF;
  AMF -- N50 --> CBCF;
  AMF -- N17 --> 5G-EIR;
  AMF -- N51 --> NEF;
  AMF -- N51i --> iNEF;
  AMF -- N26 --> MME;
  AMF -- N22 --> NSSF;
  AMF -- N11 --> SMF;
  AMF -- N15 --> PCF;
  AMF -- N55 --> UCMF;
  AMF -- N8 --> UDM;
  SMF -- N40 --> CHF;
  SMF -- N7 --> PCF;
  SMF -- N29 --> SMF;
  SMF -- N29i --> iSMF;
  SMF -- N10 --> UDM;
  SMF -- N4 --> UPF;
  LMF -- NL1 --> AMF;
  LMF -- NL7 --> LMF;
  NEF -- N33 --> AF;
  NEF -- N29 --> SMF;
  iNEF -- N29i --> SMF;
  NEF -- N56 --> UCMF;
  NEF -- N52 --> UDM;
  NEF -- N37 --> UDR;
  PCF -- N5 --> AF;
  PCF -- N28 --> CHF;
  PCF -- N30 --> NEF;
  PCF -- N23 --> NWDAF;
  PCF -- N24 --> Home-PCF;
  PCF -- N24 --> Visit-PCF;
  PCF -- N36 --> UDR;
  SMSF -- N20 --> AMF;
  UDM -- N35 --> UDR;
  AMF -- N18 --> UDSF;
  LMF -- N18 --> UDSF;
  NEF -- N18 --> UDSF;
  PCF -- N18 --> UDSF;
  SMF -- N18 --> UDSF;
  SMSF -- N18 --> UDSF;

```

## Steps

```shell
~/make -f Makefile all
```

[[]]

## References
- https://www.vaultproject.io/api-docs/secret/pki
- https://public.cyber.mil/pki-pke/interoperability/
- https://playbooks.idmanagement.gov/fpki/
- https://www.ssltrust.com/blog/understanding-certificate-cross-signing
- https://www.ietf.org/id/draft-housley-lamps-3g-nftypes-00.html#section-3
- https://www.etsi.org/deliver/etsi_ts/133300_133399/133310/16.07.00_60/ts_133310v160700p.pdf
- 

## Appendix

- 

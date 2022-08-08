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

## Appendix

- 

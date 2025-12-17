# Audit Methodology

4-phase security audit approach for smart contracts and applications.
## Audit Methodology

### Four-Phase Approach

```markdown
## Phase 1: Information Gathering (20% of time)

**Objectives:**
- Understand project architecture
- Identify critical components
- Map data flows
- Review documentation

**Deliverables:**
- Architecture diagram
- Asset inventory
- Trust boundaries
- Attack surface analysis

**Activities:**
1. Read all documentation
2. Review codebase structure
3. Identify external dependencies
4. Map user roles and permissions
5. Document critical functions
6. Create threat model
```

```markdown
## Phase 2: Automated Analysis (15% of time)

**Tools:**
- Slither (Solidity)
- Aderyn (Solidity)
- Mythril (Solidity)
- Anchor security checks (Solana)

**Process:**
1. Run all automated tools
2. Triage findings by severity
3. Eliminate false positives
4. Document tool configurations
5. Create baseline report

**Output:**
- Tool findings spreadsheet
- False positive log
- Configuration files
```

```markdown
## Phase 3: Manual Review (50% of time)

**Focus Areas:**
- Business logic flaws
- Access control
- Input validation
- State management
- External interactions
- Economic attacks

**Techniques:**
- Line-by-line code review
- Data flow analysis
- Control flow analysis
- Invariant checking
- Attack scenario modeling

**Documentation:**
- Issue tracking sheet
- Code annotations
- Question log for developers
```

```markdown
## Phase 4: Verification & Reporting (15% of time)

**Activities:**
1. Create PoC exploits
2. Verify all findings
3. Assess business impact
4. Draft recommendations
5. Write final report
6. Present findings

**Deliverables:**
- Executive summary
- Detailed findings report
- PoC exploit code
- Remediation guide
- Retest plan
```

### Audit Checklist

```markdown
# Smart Contract Security Checklist

## Access Control
- [ ] Admin functions properly protected
- [ ] Role-based access correctly implemented
- [ ] Owner transfer uses two-step process
- [ ] No orphaned contracts (missing owner)
- [ ] Timelock on critical functions
- [ ] Emergency pause mechanism exists
- [ ] Access control cannot be bypassed

## Reentrancy
- [ ] CEI pattern followed everywhere
- [ ] ReentrancyGuard on external calls
- [ ] No unsafe external calls
- [ ] State updated before transfers
- [ ] Cross-function reentrancy checked
- [ ] Read-only reentrancy considered

## Integer Operations
- [ ] SafeMath or checked operations
- [ ] No unchecked blocks without justification
- [ ] Overflow/underflow impossible
- [ ] Division by zero prevented
- [ ] Precision loss documented
- [ ] Rounding in favor of protocol

## External Calls
- [ ] Return values checked
- [ ] Gas limits appropriate
- [ ] Reentrancy protected
- [ ] Failed calls handled
- [ ] Pull over push payments
- [ ] External contract assumptions documented

## Oracle Security
- [ ] Price manipulation resistant
- [ ] Stale data checks
- [ ] Multiple oracle sources
- [ ] Outlier filtering
- [ ] Fallback mechanisms
- [ ] Oracle failure handling

## Token Interactions
- [ ] ERC20/SPL token standards followed
- [ ] Approval race conditions handled
- [ ] Transfer return values checked
- [ ] Token balance changes verified
- [ ] Flash loan attacks considered
- [ ] Token decimal handling correct

## Economic Security
- [ ] Incentive alignment verified
- [ ] MEV risks assessed
- [ ] Griefing attack prevention
- [ ] Fee manipulation impossible
- [ ] Economic exploits modeled
- [ ] Edge cases tested

## Upgradability
- [ ] Storage layout documented
- [ ] Initialization protected
- [ ] Upgrade authorization secure
- [ ] Backward compatibility considered
- [ ] Migration plan exists
- [ ] Emergency upgrade capability
```


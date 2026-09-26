param([string]$GameDirectory = 'C:\Program Files (x86)\Steam\steamapps\common\Ravenswatch')
$ErrorActionPreference = 'Stop'
try {
 if (Get-Process Ravenswatch -ErrorAction SilentlyContinue) { throw 'Close Ravenswatch completely, then run this repair again.' }
 if (-not (Test-Path -LiteralPath (Join-Path $GameDirectory 'Ravenswatch.exe'))) {
  $GameDirectory = Read-Host 'Enter the Ravenswatch folder containing Ravenswatch.exe'
 }
 if ((Get-FileHash -LiteralPath (Join-Path $GameDirectory 'Ravenswatch.exe')).Hash -ne '40430B75C72BE129F57917D865ECDC63A5EF4E4BA0A4244D950F5938CC00B2DB') { throw 'Unsupported game build. No files changed.' }
 $sdk = Join-Path $GameDirectory 'rsmm\lib\rsmm.lua'
 $text = [IO.File]::ReadAllText($sdk).Replace("`r`n", "`n")
 $old = '        obj_has_vtable = function(p) return _dispatcher_live(p) end,'
 $replacement = @'
        -- World dispatchers belong to oCEntitySceneContext at +0x340 on
        -- the installer-pinned build. Never apply the learned HERO offset here.
        obj_has_vtable = function(p)
            if not _ptr_plausible(p) or not _va_ok("R.map.reveal") then return false end
            local world = p - 0x340
            if _obj_has_vtable(world) and R.rtti and R.rtti.name
                and R.rtti.name(world) == "oCEntitySceneContext" then return true end
            -- Preserve the supported hero-scoped path, but require its owner
            -- identity rather than accepting an unrelated live hero as proof.
            if not _DISPATCHER_ENTITY_OFF then return false end
            local owner = p - _DISPATCHER_ENTITY_OFF
            return _obj_has_vtable(owner) and R.rtti and R.rtti.name
                and R.rtti.name(owner) == "oCEntity" or false
        end,
'@
 $replacement = $replacement.Replace("`r`n", "`n")
 if ($text.Contains($replacement)) { Write-Host 'Map repair already installed.'; return }
 $start = $text.IndexOf('local ok, x = _submodule_fn("map", {')
 if ($start -lt 0) { throw 'Unsupported SDK layout. No files changed.' }
 $end = $text.IndexOf('    })', $start)
 if ($end -lt 0) { throw 'Unsupported SDK layout. No files changed.' }
 $section = $text.Substring($start, $end - $start)
 if (($section.Split(@($old), [StringSplitOptions]::None).Count - 1) -ne 1) { throw 'Unsupported SDK map check. No files changed.' }
 foreach ($required in @('local function _va_ok(', 'local function _ptr_plausible(', 'local function _obj_has_vtable(', 'R.rtti.name')) {
  if (-not $text.Contains($required)) { throw "Missing SDK helper: $required. No files changed." }
 }
 $updated = $text.Substring(0,$start) + $section.Replace($old,$replacement) + $text.Substring($end)
 $backup = $sdk + '.map-backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss')
 Copy-Item -LiteralPath $sdk -Destination $backup
 try {
  [IO.File]::WriteAllText($sdk, $updated, [Text.UTF8Encoding]::new($false))
  if ([IO.File]::ReadAllText($sdk) -cne $updated) { throw 'Verification failed' }
 } catch { Copy-Item -LiteralPath $backup -Destination $sdk; throw }
 Write-Host "Map repair installed. Backup: $backup"
} catch { Write-Error $_; exit 1 }

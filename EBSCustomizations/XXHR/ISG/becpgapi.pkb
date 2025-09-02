rem dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
rem dbdrv: checkfile(115.15=120.5):~PROD:~PATH:~FILE
/*===========================================================================*
 |               Copyright (c) 2003 Oracle Corporation                       |
 |                       All rights reserved.                                |
*============================================================================*/
rem
rem File Information
rem ================
rem This file was originally copied from the bpapiskl.pkb file.
rem Skeleton Version: 115.3
rem Copy Date       : '19-Dec-2003'
rem Copied By       : skota
rem
rem --------------------------------------------------------------------------
rem 
rem Change List
rem ===========
rem 
rem Version Date        Author         Comment
rem -------+-----------+--------------+---------------------------------------
rem 115.0   19-Dec-2003 skota          Created
rem 115.1   17-Mar-2004 skota          Corrected the l_diff_ws_bdgt_iss 
rem				       calculation
rem 115.2   19-Mar-2004 skota          for LLM, ws_bdgt will become the 
rem				       bdgt_val
rem 115.3   02-Apr-2004 skota          Moved the Min, Max edit to api. Added
rem                                    new parameter p_perf_min_max_edit
rem 115.5   11-Dec-2004 steotia        Created procedure to write audit record
rem                                    in ben_cwb_audit
rem 115.6   15-Dec-2004 steotia        Added Update Manager Access Level in the
rem                                    audit types available to person groups
rem 115.7   15-Dec-2004 steotia        Writing translated meaning into 
rem                                    audit table instead of code
rem 115.8   22-Dec-2004 steotia        Modified comparison condition before 
rem                                    calling audit api
rem 115.9   28-Dec-2004 steotia        Added Update Budget Reserve (RS)
rem 115.10  11-Jan-2005 steotia        Writing person_id 
rem                                    from fnd_user.employee_id
rem 115.11  29-Aug-2005 maagrawa       Fixed the query on summary table which
rem                                    was assuming a single record.(4571515).
rem 115.12  15-Sep-2005 maagrawa       When summing values, check for nulls.
rem 115.13  22-Sep-2005 maagrawa       Check for min/max Reserve only when chg
rem 115.14  30-Sep-2005 maagrawa       Corrected check for HLM for summary upd
rem 115.15  26-May-2006 maagrawa       New parameter update_summary on delete.
rem ==========================================================================
Set Verify Off
WhenEver OSError Exit Failure Rollback;
WhenEver SqlError Exit Failure Rollback;
Create Or Replace Package Body BEN_CWB_PERSON_GROUPS_API as
/* $Header: becpgapi.pkb 120.5 2006/05/26 21:31:30 maagrawa noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  BEN_CWB_PERSON_GROUPS_API.';
g_debug boolean := hr_utility.debug_enabled;
--
  cursor csr_grps(v_group_per_in_ler_id number
                 ,v_group_pl_id number
                 ,v_group_oipl_id number) is
     select *
     from ben_cwb_person_groups
     where group_per_in_ler_id = v_group_per_in_ler_id
     and   group_pl_id = v_group_pl_id
     and   group_oipl_id = v_group_oipl_id;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_group_budget >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_group_budget
  (p_validate                      in     boolean  default false
  ,p_group_per_in_ler_id           in     number  
  ,p_group_pl_id                   in     number  
  ,p_group_oipl_id                 in     number  
  ,p_lf_evt_ocrd_dt                in     date    
  ,p_bdgt_pop_cd                   in     varchar2   default null 
  ,p_due_dt                        in     date       default null 
  ,p_access_cd                     in     varchar2   default null 
  ,p_approval_cd                   in     varchar2   default null 
  ,p_approval_date                 in     date       default null 
  ,p_approval_comments             in     varchar2   default null 
  ,p_dist_bdgt_val                 in     number     default null 
  ,p_ws_bdgt_val                   in     number     default null 
  ,p_rsrv_val                      in     number     default null 
  ,p_dist_bdgt_mn_val              in     number     default null 
  ,p_dist_bdgt_mx_val              in     number     default null 
  ,p_dist_bdgt_incr_val            in     number     default null 
  ,p_ws_bdgt_mn_val                in     number     default null 
  ,p_ws_bdgt_mx_val                in     number     default null 
  ,p_ws_bdgt_incr_val              in     number     default null 
  ,p_rsrv_mn_val                   in     number     default null 
  ,p_rsrv_mx_val                   in     number     default null 
  ,p_rsrv_incr_val                 in     number     default null 
  ,p_dist_bdgt_iss_val             in     number     default null 
  ,p_ws_bdgt_iss_val               in     number     default null 
  ,p_dist_bdgt_iss_date            in     date       default null 
  ,p_ws_bdgt_iss_date              in     date       default null 
  ,p_ws_bdgt_val_last_upd_date     in     date       default null 
  ,p_dist_bdgt_val_last_upd_date   in     date       default null 
  ,p_rsrv_val_last_upd_date        in     date       default null 
  ,p_ws_bdgt_val_last_upd_by       in     number     default null 
  ,p_dist_bdgt_val_last_upd_by     in     number     default null 
  ,p_rsrv_val_last_upd_by          in     number     default null 
  ,p_submit_cd                     in     varchar2   default null 
  ,p_submit_date                   in     date       default null 
  ,p_submit_comments               in     varchar2   default null
  ,p_object_version_number            out nocopy     number
  ) is
  --
  l_object_version_number number;
  --
  l_proc                varchar2(72) := g_package||'create_group_budget';
begin
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint create_group_budget;
  --
  -- Call Before Process User Hook
  --
  begin
    ben_cwb_person_groups_bk1.create_group_budget_b
        (p_group_per_in_ler_id           =>   p_group_per_in_ler_id         
        ,p_group_pl_id                   =>   p_group_pl_id                 
        ,p_group_oipl_id                 =>   p_group_oipl_id               
        ,p_lf_evt_ocrd_dt                =>   p_lf_evt_ocrd_dt              
        ,p_bdgt_pop_cd                   =>   p_bdgt_pop_cd                 
        ,p_due_dt                        =>   p_due_dt                      
        ,p_access_cd                     =>   p_access_cd                   
        ,p_approval_cd                   =>   p_approval_cd                 
        ,p_approval_date                 =>   p_approval_date               
        ,p_approval_comments             =>   p_approval_comments           
        ,p_dist_bdgt_val                 =>   p_dist_bdgt_val               
        ,p_ws_bdgt_val                   =>   p_ws_bdgt_val                 
        ,p_rsrv_val                      =>   p_rsrv_val                    
        ,p_dist_bdgt_mn_val              =>   p_dist_bdgt_mn_val            
        ,p_dist_bdgt_mx_val              =>   p_dist_bdgt_mx_val            
        ,p_dist_bdgt_incr_val            =>   p_dist_bdgt_incr_val          
        ,p_ws_bdgt_mn_val                =>   p_ws_bdgt_mn_val              
        ,p_ws_bdgt_mx_val                =>   p_ws_bdgt_mx_val              
        ,p_ws_bdgt_incr_val              =>   p_ws_bdgt_incr_val            
        ,p_rsrv_mn_val                   =>   p_rsrv_mn_val                 
        ,p_rsrv_mx_val                   =>   p_rsrv_mx_val                 
        ,p_rsrv_incr_val                 =>   p_rsrv_incr_val               
        ,p_dist_bdgt_iss_val             =>   p_dist_bdgt_iss_val           
        ,p_ws_bdgt_iss_val               =>   p_ws_bdgt_iss_val             
        ,p_dist_bdgt_iss_date            =>   p_dist_bdgt_iss_date          
        ,p_ws_bdgt_iss_date              =>   p_ws_bdgt_iss_date            
        ,p_ws_bdgt_val_last_upd_date     =>   p_ws_bdgt_val_last_upd_date   
        ,p_dist_bdgt_val_last_upd_date   =>   p_dist_bdgt_val_last_upd_date 
        ,p_rsrv_val_last_upd_date        =>   p_rsrv_val_last_upd_date      
        ,p_ws_bdgt_val_last_upd_by       =>   p_ws_bdgt_val_last_upd_by     
        ,p_dist_bdgt_val_last_upd_by     =>   p_dist_bdgt_val_last_upd_by   
        ,p_rsrv_val_last_upd_by          =>   p_rsrv_val_last_upd_by        
        ,p_submit_cd                     =>   p_submit_cd                   
        ,p_submit_date                   =>   p_submit_date                 
        ,p_submit_comments               =>   p_submit_comments        
        );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_group_budget'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --   
  --
  -- Process Logic  
  --
  ben_cpg_ins.ins
         (p_group_per_in_ler_id           =>   p_group_per_in_ler_id         
         ,p_group_pl_id                   =>   p_group_pl_id                 
         ,p_group_oipl_id                 =>   p_group_oipl_id               
         ,p_lf_evt_ocrd_dt                =>   p_lf_evt_ocrd_dt              
         ,p_bdgt_pop_cd                   =>   p_bdgt_pop_cd                 
         ,p_due_dt                        =>   p_due_dt                      
         ,p_access_cd                     =>   p_access_cd                   
         ,p_approval_cd                   =>   p_approval_cd                 
         ,p_approval_date                 =>   p_approval_date               
         ,p_approval_comments             =>   p_approval_comments           
         ,p_dist_bdgt_val                 =>   p_dist_bdgt_val               
         ,p_ws_bdgt_val                   =>   p_ws_bdgt_val                 
         ,p_rsrv_val                      =>   p_rsrv_val                    
         ,p_dist_bdgt_mn_val              =>   p_dist_bdgt_mn_val            
         ,p_dist_bdgt_mx_val              =>   p_dist_bdgt_mx_val            
         ,p_dist_bdgt_incr_val            =>   p_dist_bdgt_incr_val          
         ,p_ws_bdgt_mn_val                =>   p_ws_bdgt_mn_val              
         ,p_ws_bdgt_mx_val                =>   p_ws_bdgt_mx_val              
         ,p_ws_bdgt_incr_val              =>   p_ws_bdgt_incr_val            
         ,p_rsrv_mn_val                   =>   p_rsrv_mn_val                 
         ,p_rsrv_mx_val                   =>   p_rsrv_mx_val                 
         ,p_rsrv_incr_val                 =>   p_rsrv_incr_val               
         ,p_dist_bdgt_iss_val             =>   p_dist_bdgt_iss_val           
         ,p_ws_bdgt_iss_val               =>   p_ws_bdgt_iss_val             
         ,p_dist_bdgt_iss_date            =>   p_dist_bdgt_iss_date          
         ,p_ws_bdgt_iss_date              =>   p_ws_bdgt_iss_date            
         ,p_ws_bdgt_val_last_upd_date     =>   p_ws_bdgt_val_last_upd_date   
         ,p_dist_bdgt_val_last_upd_date   =>   p_dist_bdgt_val_last_upd_date 
         ,p_rsrv_val_last_upd_date        =>   p_rsrv_val_last_upd_date      
         ,p_ws_bdgt_val_last_upd_by       =>   p_ws_bdgt_val_last_upd_by     
         ,p_dist_bdgt_val_last_upd_by     =>   p_dist_bdgt_val_last_upd_by   
         ,p_rsrv_val_last_upd_by          =>   p_rsrv_val_last_upd_by        
         ,p_submit_cd                     =>   p_submit_cd                   
         ,p_submit_date                   =>   p_submit_date                 
         ,p_submit_comments               =>   p_submit_comments
         ,p_object_version_number         =>   l_object_version_number
         );
  --
  -- Call After Process User Hook
  --
  begin
    ben_cwb_person_groups_bk1.create_group_budget_a
        (p_group_per_in_ler_id           =>   p_group_per_in_ler_id         
        ,p_group_pl_id                   =>   p_group_pl_id                 
        ,p_group_oipl_id                 =>   p_group_oipl_id               
        ,p_lf_evt_ocrd_dt                =>   p_lf_evt_ocrd_dt              
        ,p_bdgt_pop_cd                   =>   p_bdgt_pop_cd                 
        ,p_due_dt                        =>   p_due_dt                      
        ,p_access_cd                     =>   p_access_cd                   
        ,p_approval_cd                   =>   p_approval_cd                 
        ,p_approval_date                 =>   p_approval_date               
        ,p_approval_comments             =>   p_approval_comments           
        ,p_dist_bdgt_val                 =>   p_dist_bdgt_val               
        ,p_ws_bdgt_val                   =>   p_ws_bdgt_val                 
        ,p_rsrv_val                      =>   p_rsrv_val                    
        ,p_dist_bdgt_mn_val              =>   p_dist_bdgt_mn_val            
        ,p_dist_bdgt_mx_val              =>   p_dist_bdgt_mx_val            
        ,p_dist_bdgt_incr_val            =>   p_dist_bdgt_incr_val          
        ,p_ws_bdgt_mn_val                =>   p_ws_bdgt_mn_val              
        ,p_ws_bdgt_mx_val                =>   p_ws_bdgt_mx_val              
        ,p_ws_bdgt_incr_val              =>   p_ws_bdgt_incr_val            
        ,p_rsrv_mn_val                   =>   p_rsrv_mn_val                 
        ,p_rsrv_mx_val                   =>   p_rsrv_mx_val                 
        ,p_rsrv_incr_val                 =>   p_rsrv_incr_val               
        ,p_dist_bdgt_iss_val             =>   p_dist_bdgt_iss_val           
        ,p_ws_bdgt_iss_val               =>   p_ws_bdgt_iss_val             
        ,p_dist_bdgt_iss_date            =>   p_dist_bdgt_iss_date          
        ,p_ws_bdgt_iss_date              =>   p_ws_bdgt_iss_date            
        ,p_ws_bdgt_val_last_upd_date     =>   p_ws_bdgt_val_last_upd_date   
        ,p_dist_bdgt_val_last_upd_date   =>   p_dist_bdgt_val_last_upd_date 
        ,p_rsrv_val_last_upd_date        =>   p_rsrv_val_last_upd_date      
        ,p_ws_bdgt_val_last_upd_by       =>   p_ws_bdgt_val_last_upd_by     
        ,p_dist_bdgt_val_last_upd_by     =>   p_dist_bdgt_val_last_upd_by   
        ,p_rsrv_val_last_upd_by          =>   p_rsrv_val_last_upd_by        
        ,p_submit_cd                     =>   p_submit_cd                   
        ,p_submit_date                   =>   p_submit_date                 
        ,p_submit_comments               =>   p_submit_comments 
        ,p_object_version_number         =>   l_object_version_number        
        );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_group_budget'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number  := l_object_version_number;  
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_group_budget;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_group_budget;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end create_group_budget;
--
--
-- --------------------------------------------------------------------------
-- |----------------------------< check_min_max >----------------------------|
-- --------------------------------------------------------------------------
procedure check_min_max(p_val in number
                       ,p_iss_val in number
		       ,p_min_val in number
		       ,p_max_val in number
		       ,p_incr_val in number
		       ,p_group_per_in_ler_id number)
is
--
  l_person_name varchar2(240);
--
  l_proc  varchar2(72) := g_package||'check_min_max';
--
Begin
  --
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 10);
     hr_utility.set_location('Entering:'||l_proc, 10);
     hr_utility.set_location('p_val :'||p_val, 10);
     hr_utility.set_location('p_iss_val :'||p_iss_val,10);
     hr_utility.set_location('p_min_val :'||p_min_val, 10);
     hr_utility.set_location('p_max_val :'||p_max_val, 10);
     hr_utility.set_location('p_incr_val :'||p_incr_val, 10);
  end if;
  --
  select full_name into l_person_name
  from ben_cwb_person_info
  where group_per_in_ler_id = p_group_per_in_ler_id;
  --
  --
  if g_debug then
     hr_utility.set_location(l_proc, 20);
  end if;
  --
  if (p_val is not null and p_val <> hr_api.g_number and 
      p_min_val is not null) then
    if (p_val < p_min_val) then
      fnd_message.set_name('BEN','BEN_92984_CWB_VAL_NOT_IN_RANGE');
      fnd_message.set_token('VAL',p_val);
      fnd_message.set_token('MIN',p_min_val);
      fnd_message.set_token('MAX',p_max_val);
      fnd_message.set_token('PERSON',l_person_name);
      fnd_message.raise_error;   
    end if;
  end if;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 30);
  end if;
  --
  if (p_iss_val is not null and p_iss_val <> hr_api.g_number and 
      p_min_val is not null) then
    if (p_iss_val < p_min_val) then
      fnd_message.set_name('BEN','BEN_92984_CWB_VAL_NOT_IN_RANGE');
      fnd_message.set_token('VAL',p_iss_val);
      fnd_message.set_token('MIN',p_min_val);
      fnd_message.set_token('MAX',p_max_val);
      fnd_message.set_token('PERSON',l_person_name);
      fnd_message.raise_error;   
    end if;
  end if;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 40);
  end if;
  --
  if (p_val is not null and p_val <> hr_api.g_number and 
      p_max_val is not null) then
    if (p_val > p_max_val) then
      fnd_message.set_name('BEN','BEN_92984_CWB_VAL_NOT_IN_RANGE');
      fnd_message.set_token('VAL',p_val);
      fnd_message.set_token('MIN',p_min_val);
      fnd_message.set_token('MAX',p_max_val);
      fnd_message.set_token('PERSON',l_person_name);
      fnd_message.raise_error;   
    end if;
  end if;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 50);
  end if;
  --
  if (p_iss_val is not null and p_iss_val <> hr_api.g_number and 
      p_max_val is not null) then
    if (p_iss_val > p_max_val) then
      fnd_message.set_name('BEN','BEN_92984_CWB_VAL_NOT_IN_RANGE');
      fnd_message.set_token('VAL',p_iss_val);
      fnd_message.set_token('MIN',p_min_val);
      fnd_message.set_token('MAX',p_max_val);
      fnd_message.set_token('PERSON',l_person_name);
      fnd_message.raise_error;   
    end if;
  end if;
  --
  if g_debug then
     hr_utility.set_location(l_proc, 60);
  end if;
  --
  if (p_val is not null and p_val <> hr_api.g_number and
      p_incr_val is not null) then
    if (mod(p_val,p_incr_val) <> 0) then
      fnd_message.set_name('BEN','BEN_92985_CWB_VAL_NOT_INCRMNT');
      fnd_message.set_token('VAL',p_val);
      fnd_message.set_token('INCREMENT', p_incr_val);
      fnd_message.set_token('PERSON',l_person_name);
      fnd_message.raise_error;   
    end if;
  end if;
  if g_debug then
     hr_utility.set_location(l_proc, 70);
  end if;
  --
  if (p_iss_val is not null and p_iss_val <> hr_api.g_number and
      p_incr_val is not null) then
    if (mod(p_iss_val,p_incr_val) <> 0) then
      fnd_message.set_name('BEN','BEN_92985_CWB_VAL_NOT_INCRMNT');
      fnd_message.set_token('VAL',p_iss_val);
      fnd_message.set_token('INCREMENT', p_incr_val);
      fnd_message.set_token('PERSON',l_person_name);
      fnd_message.raise_error;   
    end if;
  end if;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 90);
  end if;
end check_min_max;
--
-- --------------------------------------------------------------------------
-- |---------------------< update_group_budget_summary >---------------------|
-- --------------------------------------------------------------------------
-- Description 
-- This is an internal procedure called only by update_group_budget to 
-- update the summary table after updating the ben_cwb_person_groups.
--
procedure update_group_budget_summary
         (p_grp_bdgt_old csr_grps%rowtype
         ,p_dist_bdgt_val number
         ,p_ws_bdgt_val number
         ,p_dist_bdgt_iss_val number
         ,p_ws_bdgt_iss_val number) is
   --cursor to fetch the managers of the person 
   cursor csr_mgr_pil_ids(p_group_per_in_ler_id number) is
   select mgr_per_in_ler_id 
   from ben_cwb_group_hrchy 
   where emp_per_in_ler_id = p_group_per_in_ler_id
   and lvl_num  > 0
   order by lvl_num;
   --
   l_prsrv_bdgt_cd varchar2(30);
   l_uses_bdgt_flag varchar2(30);
   --
   l_dist_bdgt_val number;
   l_ws_bdgt_val number;
   l_dist_bdgt_iss_val number;
   l_ws_bdgt_iss_val number;
   --
   l_diff_dist_bdgt number;
   l_diff_ws_bdgt number;
   l_diff_dist_bdgt_iss number;
   l_diff_ws_bdgt_iss number;
   --
   l_elig_sal_direct number;
   l_elig_sal_all number;
   --
   l_immediate_mgr number;
--
   l_proc     varchar2(72) := g_package||'update_group_budget_summary';
--   
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   select uses_bdgt_flag, prsrv_bdgt_cd 
   into l_uses_bdgt_flag, l_prsrv_bdgt_cd
   from ben_cwb_pl_dsgn pl
   where pl.pl_id = p_grp_bdgt_old.group_pl_id
   and   pl.lf_evt_ocrd_dt = p_grp_bdgt_old.lf_evt_ocrd_dt
   and   pl.oipl_id = p_grp_bdgt_old.group_oipl_id;
   --
   if l_uses_bdgt_flag is null or l_uses_bdgt_flag <> 'Y' then
     return;
   end if;
   --
   -- set the parameters to old values if they are default values.
   if p_dist_bdgt_val = hr_api.g_number then
      l_dist_bdgt_val := p_grp_bdgt_old.dist_bdgt_val;
   else 
      l_dist_bdgt_val := p_dist_bdgt_val;
   end if;
   if p_ws_bdgt_val = hr_api.g_number then
      l_ws_bdgt_val := p_grp_bdgt_old.ws_bdgt_val;
   else 
      l_ws_bdgt_val := p_ws_bdgt_val;
   end if;
   if p_dist_bdgt_iss_val = hr_api.g_number then
      l_dist_bdgt_iss_val := p_grp_bdgt_old.dist_bdgt_iss_val;
   else 
      l_dist_bdgt_iss_val := p_dist_bdgt_iss_val;
   end if;
   if p_ws_bdgt_iss_val = hr_api.g_number then
      l_ws_bdgt_iss_val := p_grp_bdgt_old.ws_bdgt_iss_val;
   else 
      l_ws_bdgt_iss_val := p_ws_bdgt_iss_val;
   end if;
   --
   if g_debug then
      hr_utility.set_location(l_proc, 20);
   end if;
   --   
   if nvl(p_grp_bdgt_old.dist_bdgt_val,0) <> nvl(l_dist_bdgt_val,0) or
      nvl(p_grp_bdgt_old.ws_bdgt_val,0) <> nvl(l_ws_bdgt_val,0) or
      nvl(p_grp_bdgt_old.dist_bdgt_iss_val,0) <> nvl(l_dist_bdgt_iss_val,0) or
      nvl(p_grp_bdgt_old.ws_bdgt_iss_val,0) <> nvl(l_ws_bdgt_iss_val,0) then
      --
      --
      if g_debug then
         hr_utility.set_location(l_proc, 30);
      end if;
      --   
      if l_prsrv_bdgt_cd = 'A' then
         --
         if g_debug then
            hr_utility.set_location(l_proc, 40);
         end if;
         --               
         l_diff_dist_bdgt := ben_cwb_utils.add_number_with_null_check
                             (l_dist_bdgt_val,
                              - p_grp_bdgt_old.dist_bdgt_val);
         l_diff_ws_bdgt := ben_cwb_utils.add_number_with_null_check
                            (l_ws_bdgt_val,
                              - p_grp_bdgt_old.ws_bdgt_val);
         l_diff_dist_bdgt_iss := ben_cwb_utils.add_number_with_null_check
                                (l_dist_bdgt_iss_val,
                                 - p_grp_bdgt_old.dist_bdgt_iss_val);
         l_diff_ws_bdgt_iss := ben_cwb_utils.add_number_with_null_check
                                (l_ws_bdgt_iss_val,
                                 - p_grp_bdgt_old.ws_bdgt_iss_val);
         --
      else
         --
         if g_debug then
            hr_utility.set_location(l_proc, 50);
         end if;
         --         
         select sum(elig_sal_val_direct) elig_sal_val_direct
               ,sum(elig_sal_val_all) elig_sal_val_all
         into   l_elig_sal_direct
               ,l_elig_sal_all
         from ben_cwb_summary
         where group_per_in_ler_id = p_grp_bdgt_old.group_per_in_ler_id
         and   group_pl_id = p_grp_bdgt_old.group_pl_id
         and   group_oipl_id = p_grp_bdgt_old.group_oipl_id;
         --
         l_diff_dist_bdgt := ben_cwb_utils.add_number_with_null_check
                             (l_dist_bdgt_val,
                            -p_grp_bdgt_old.dist_bdgt_val)*l_elig_sal_all/100;
         l_diff_ws_bdgt := ben_cwb_utils.add_number_with_null_check
                            (l_ws_bdgt_val,
                            -p_grp_bdgt_old.ws_bdgt_val)*l_elig_sal_direct/100;
         l_diff_dist_bdgt_iss := ben_cwb_utils.add_number_with_null_check
                               (l_dist_bdgt_iss_val,
                                -p_grp_bdgt_old.dist_bdgt_iss_val)*l_elig_sal_all/100;
         l_diff_ws_bdgt_iss := ben_cwb_utils.add_number_with_null_check
                                (l_ws_bdgt_iss_val,
                                -p_grp_bdgt_old.ws_bdgt_iss_val)*l_elig_sal_direct/100;
         --
      end if;
      --
      -- If no distribution budget, then the manager is
      -- not allowed to budget, so use worksheet budget.
      --
      if (l_diff_dist_bdgt is null) then
         l_diff_dist_bdgt := l_diff_ws_bdgt;
         l_diff_dist_bdgt_iss := l_diff_ws_bdgt_iss;
      end if;
      --
      if g_debug then
         hr_utility.set_location(l_proc, 60);
      end if;
      --               
      -- The first one will be the immediate manager
      l_immediate_mgr := 1;
      for mgr in csr_mgr_pil_ids(p_grp_bdgt_old.group_per_in_ler_id)
      loop
         --
         if g_debug then
            hr_utility.set_location(l_proc, 70);
         end if;
         --               
         ben_cwb_summary_pkg.update_or_insert_pl_sql_tab
            (p_group_per_in_ler_id    => mgr.mgr_per_in_ler_id
            ,p_group_pl_id            => p_grp_bdgt_old.group_pl_id
            ,p_group_oipl_id          => p_grp_bdgt_old.group_oipl_id
            ,p_ws_bdgt_val_direct     => l_diff_ws_bdgt * l_immediate_mgr
            ,p_ws_bdgt_val_all        => l_diff_ws_bdgt 
            ,p_ws_bdgt_iss_val_direct => l_diff_ws_bdgt_iss*l_immediate_mgr
            ,p_ws_bdgt_iss_val_all    => l_diff_ws_bdgt_iss
            ,p_bdgt_val_direct        => l_diff_dist_bdgt  * l_immediate_mgr
            ,p_bdgt_iss_val_direct    => l_diff_dist_bdgt_iss*l_immediate_mgr
            );
         l_immediate_mgr := 0;
      end loop;
   end if; -- of difference in ws or db budget values
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 999);
   end if;
   --   
end; -- update_group_budget_summary
--
--
-- -------------------------------------------------------------------------
-- |-------------------------< create_audit_record >-----------------------|
-- -------------------------------------------------------------------------
--
-- Description
-- This is an internal procedure 
--
procedure create_audit_record
         (p_grp_bdgt_old          in         csr_grps%rowtype
         ) is
   l_grp_bdgt_new csr_grps%rowtype;
   l_pl_dsgn ben_cwb_pl_dsgn%rowtype;
   l_cwb_audit_id ben_cwb_audit.cwb_audit_id%type;
   l_object_version_number ben_cwb_audit.object_version_number%type;
   l_cd_meaning_old hr_lookups.meaning%type;
   l_cd_meaning_new hr_lookups.meaning%type;
   l_proc                varchar2(72) := g_package||'create_audit_record';
   l_person_id fnd_user.employee_id%type;

 begin
 
  if g_debug then
     hr_utility.set_location('Entering :'|| l_proc, 100);
  end if;

  open  csr_grps(p_grp_bdgt_old.group_per_in_ler_id
                ,p_grp_bdgt_old.group_pl_id
                ,p_grp_bdgt_old.group_oipl_id);
  fetch csr_grps into l_grp_bdgt_new;
  close csr_grps;
  
   select * into l_pl_dsgn
   from ben_cwb_pl_dsgn
   where pl_id = p_grp_bdgt_old.group_pl_id
   and lf_evt_ocrd_dt = p_grp_bdgt_old.lf_evt_ocrd_dt
   and oipl_id = -1;

   select employee_id into l_person_id
   from fnd_user
   where user_id = l_grp_bdgt_new.last_updated_by;

    if(  ((p_grp_bdgt_old.ws_bdgt_val is null) 
      and (l_grp_bdgt_new.ws_bdgt_val is not null))
      or ((l_grp_bdgt_new.ws_bdgt_val is null) 
      and (p_grp_bdgt_old.ws_bdgt_val is not null))
      or (p_grp_bdgt_old.ws_bdgt_val <> l_grp_bdgt_new.ws_bdgt_val) ) then

   -- if(nvl(p_grp_bdgt_old.ws_bdgt_val,-1)<>nvl(l_grp_bdgt_new.ws_bdgt_val,-1)) then 
    if(l_pl_dsgn.prsrv_bdgt_cd='A') then 
      if(ben_cwb_audit_api.return_lookup_validity('BAD')=true) then

        if g_debug then
          hr_utility.set_location('Entering BAD:'||l_proc||p_grp_bdgt_old.ws_bdgt_val||' '||l_grp_bdgt_new.ws_bdgt_val, 101);
        end if;

       ben_cwb_audit_api.create_audit_entry
             (p_group_per_in_ler_id      => l_grp_bdgt_new.group_per_in_ler_id
             ,p_group_pl_id              => l_grp_bdgt_new.group_pl_id
             ,p_lf_evt_ocrd_dt           => l_grp_bdgt_new.lf_evt_ocrd_dt
             ,p_pl_id                    => l_grp_bdgt_new.group_pl_id
             ,p_group_oipl_id            => l_grp_bdgt_new.group_oipl_id
             ,p_audit_type_cd            => 'BAD'
             ,p_old_val_number           => p_grp_bdgt_old.ws_bdgt_val
             ,p_new_val_number           => l_grp_bdgt_new.ws_bdgt_val
             ,p_date_stamp               => sysdate
             ,p_change_made_by_person_id => l_person_id
             ,p_cwb_audit_id             => l_cwb_audit_id
             ,p_object_version_number    => l_object_version_number
             );
      end if;
    elsif(l_pl_dsgn.prsrv_bdgt_cd='P') then
      if(ben_cwb_audit_api.return_lookup_validity('BPD')=true) then
        if g_debug then
          hr_utility.set_location('Entering BPD:'||l_proc||p_grp_bdgt_old.ws_bdgt_val||' '||l_grp_bdgt_new.ws_bdgt_val, 102);
        end if;

       ben_cwb_audit_api.create_audit_entry
             (p_group_per_in_ler_id      => l_grp_bdgt_new.group_per_in_ler_id
             ,p_group_pl_id              => l_grp_bdgt_new.group_pl_id
             ,p_lf_evt_ocrd_dt           => l_grp_bdgt_new.lf_evt_ocrd_dt
             ,p_pl_id                    => l_grp_bdgt_new.group_pl_id
             ,p_group_oipl_id            => l_grp_bdgt_new.group_oipl_id
             ,p_audit_type_cd            => 'BPD'
             ,p_old_val_number           => p_grp_bdgt_old.ws_bdgt_val
             ,p_new_val_number           => l_grp_bdgt_new.ws_bdgt_val
             ,p_date_stamp               => sysdate
             ,p_change_made_by_person_id => l_person_id
             ,p_cwb_audit_id             => l_cwb_audit_id
             ,p_object_version_number    => l_object_version_number
             );
    end if;
   end if;
  end if;

  if(  ((p_grp_bdgt_old.dist_bdgt_val is null) 
    and (l_grp_bdgt_new.dist_bdgt_val is not null))
    or ((l_grp_bdgt_new.dist_bdgt_val is null) 
    and (p_grp_bdgt_old.dist_bdgt_val is not null))
     or (p_grp_bdgt_old.dist_bdgt_val <> l_grp_bdgt_new.dist_bdgt_val) ) then
  --if(nvl(p_grp_bdgt_old.dist_bdgt_val,-1)<>nvl(l_grp_bdgt_new.dist_bdgt_val,-1)) then 
   if(l_pl_dsgn.prsrv_bdgt_cd='A') then 
    if(ben_cwb_audit_api.return_lookup_validity('BAA')=true) then
        if g_debug then
          hr_utility.set_location('Entering BAA:'||l_proc||p_grp_bdgt_old.dist_bdgt_val||' '||l_grp_bdgt_new.dist_bdgt_val, 103);
        end if;

     ben_cwb_audit_api.create_audit_entry
              (p_group_per_in_ler_id  => l_grp_bdgt_new.group_per_in_ler_id
              ,p_group_pl_id          => l_grp_bdgt_new.group_pl_id
              ,p_lf_evt_ocrd_dt       => l_grp_bdgt_new.lf_evt_ocrd_dt
              ,p_pl_id                => l_grp_bdgt_new.group_pl_id
              ,p_group_oipl_id        => l_grp_bdgt_new.group_oipl_id
              ,p_audit_type_cd        => 'BAA'
              ,p_old_val_number       => p_grp_bdgt_old.dist_bdgt_val
              ,p_new_val_number       => l_grp_bdgt_new.dist_bdgt_val
              ,p_date_stamp           => sysdate
              ,p_change_made_by_person_id => l_person_id
              ,p_cwb_audit_id          => l_cwb_audit_id
              ,p_object_version_number => l_object_version_number
              );
      end if;
    elsif(l_pl_dsgn.prsrv_bdgt_cd='P') then
      if(ben_cwb_audit_api.return_lookup_validity('BPA')=true) then
        if g_debug then
          hr_utility.set_location('Entering BPA:'||l_proc||p_grp_bdgt_old.dist_bdgt_val||' '||l_grp_bdgt_new.dist_bdgt_val, 104);
        end if;

       ben_cwb_audit_api.create_audit_entry
               (p_group_per_in_ler_id      => l_grp_bdgt_new.group_per_in_ler_id
               ,p_group_pl_id              => l_grp_bdgt_new.group_pl_id
               ,p_lf_evt_ocrd_dt           => l_grp_bdgt_new.lf_evt_ocrd_dt
               ,p_pl_id                    => l_grp_bdgt_new.group_pl_id
               ,p_group_oipl_id            => l_grp_bdgt_new.group_oipl_id
               ,p_audit_type_cd            => 'BPA'
               ,p_old_val_number           => p_grp_bdgt_old.dist_bdgt_val
               ,p_new_val_number           => l_grp_bdgt_new.dist_bdgt_val
               ,p_date_stamp               => sysdate
               ,p_change_made_by_person_id => l_person_id
               ,p_cwb_audit_id             => l_cwb_audit_id
               ,p_object_version_number    => l_object_version_number
               );
    end if;
   end if;
  end if;

  if(  ((p_grp_bdgt_old.bdgt_pop_cd is null) 
    and (l_grp_bdgt_new.bdgt_pop_cd is not null))
    or ((l_grp_bdgt_new.bdgt_pop_cd is null) 
    and (p_grp_bdgt_old.bdgt_pop_cd is not null))
     or (p_grp_bdgt_old.bdgt_pop_cd <> l_grp_bdgt_new.bdgt_pop_cd) ) then
  -- if(nvl(p_grp_bdgt_old.bdgt_pop_cd,-1)<>nvl(l_grp_bdgt_new.bdgt_pop_cd,-1)) then 
   if(ben_cwb_audit_api.return_lookup_validity('BP')=true) then

        if g_debug then
          hr_utility.set_location('Entering BP:'||l_proc||p_grp_bdgt_old.bdgt_pop_cd||' '||l_grp_bdgt_new.bdgt_pop_cd, 105);
        end if;

       ben_cwb_audit_api.create_audit_entry
                (p_group_per_in_ler_id      => l_grp_bdgt_new.group_per_in_ler_id
                ,p_group_pl_id              => l_grp_bdgt_new.group_pl_id
                ,p_lf_evt_ocrd_dt           => l_grp_bdgt_new.lf_evt_ocrd_dt
                ,p_pl_id                    => l_grp_bdgt_new.group_pl_id
                ,p_group_oipl_id            => l_grp_bdgt_new.group_oipl_id
                ,p_audit_type_cd            => 'BP'
                ,p_old_val_varchar          => p_grp_bdgt_old.bdgt_pop_cd
                ,p_new_val_varchar          => l_grp_bdgt_new.bdgt_pop_cd
                ,p_date_stamp               => sysdate
                ,p_change_made_by_person_id => l_person_id
                ,p_cwb_audit_id             => l_cwb_audit_id
                ,p_object_version_number    => l_object_version_number
                );
   end if;
  end if;
  if(  ((p_grp_bdgt_old.due_dt is null) 
    and (l_grp_bdgt_new.due_dt is not null))
    or ((l_grp_bdgt_new.due_dt is null) 
    and (p_grp_bdgt_old.due_dt is not null))
     or (p_grp_bdgt_old.due_dt <> l_grp_bdgt_new.due_dt) ) then
   if(ben_cwb_audit_api.return_lookup_validity('DD')=true) then

        if g_debug then
          hr_utility.set_location('Entering DD:'||l_proc||p_grp_bdgt_old.due_dt||' '||l_grp_bdgt_new.due_dt, 106);
        end if;

       ben_cwb_audit_api.create_audit_entry
                (p_group_per_in_ler_id      => l_grp_bdgt_new.group_per_in_ler_id
                ,p_group_pl_id              => l_grp_bdgt_new.group_pl_id
                ,p_lf_evt_ocrd_dt           => l_grp_bdgt_new.lf_evt_ocrd_dt
                ,p_pl_id                    => l_grp_bdgt_new.group_pl_id
                ,p_group_oipl_id            => l_grp_bdgt_new.group_oipl_id
                ,p_audit_type_cd            => 'DD'
                ,p_old_val_date             => p_grp_bdgt_old.due_dt
                ,p_new_val_date             => l_grp_bdgt_new.due_dt
                ,p_date_stamp               => sysdate
                ,p_change_made_by_person_id => l_person_id
                ,p_cwb_audit_id             => l_cwb_audit_id
                ,p_object_version_number    => l_object_version_number
                );
   end if;
  end if;
  if(  ((p_grp_bdgt_old.submit_date is null) 
    and (l_grp_bdgt_new.submit_date is not null))
    or ((l_grp_bdgt_new.submit_date is null) 
    and (p_grp_bdgt_old.submit_date is not null))
     or (p_grp_bdgt_old.submit_date <> l_grp_bdgt_new.submit_date) ) then
   if(ben_cwb_audit_api.return_lookup_validity('SD')=true) then

        if g_debug then
          hr_utility.set_location('Entering SD: '||l_proc||p_grp_bdgt_old.submit_date||' '||l_grp_bdgt_new.submit_date, 107);
        end if;

       ben_cwb_audit_api.create_audit_entry
                (p_group_per_in_ler_id      => l_grp_bdgt_new.group_per_in_ler_id
                ,p_group_pl_id              => l_grp_bdgt_new.group_pl_id
                ,p_lf_evt_ocrd_dt           => l_grp_bdgt_new.lf_evt_ocrd_dt
                ,p_pl_id                    => l_grp_bdgt_new.group_pl_id
                ,p_group_oipl_id            => l_grp_bdgt_new.group_oipl_id
                ,p_audit_type_cd            => 'SD'
                ,p_old_val_date             => p_grp_bdgt_old.submit_date
                ,p_new_val_date             => l_grp_bdgt_new.submit_date
                ,p_date_stamp               => sysdate
                ,p_change_made_by_person_id => l_person_id
                ,p_cwb_audit_id             => l_cwb_audit_id
                ,p_object_version_number    => l_object_version_number
                );
   end if;
  end if;
  if(  ((p_grp_bdgt_old.submit_cd is null) 
    and (l_grp_bdgt_new.submit_cd is not null))
    or ((l_grp_bdgt_new.submit_cd is null) 
    and (p_grp_bdgt_old.submit_cd is not null))
     or (p_grp_bdgt_old.submit_cd <> l_grp_bdgt_new.submit_cd) ) then
   if(ben_cwb_audit_api.return_lookup_validity('SU')=true) then

       begin
        select meaning into l_cd_meaning_old 
        from hr_lookups 
        where lookup_type='BEN_SUBMIT_STAT'
        and lookup_code=p_grp_bdgt_old.submit_cd;
       exception
        when no_data_found then
        l_cd_meaning_old:=null;
       end;

       begin
        select meaning into l_cd_meaning_new 
        from hr_lookups 
        where lookup_type='BEN_SUBMIT_STAT'
        and lookup_code=l_grp_bdgt_new.submit_cd;
       exception
       when no_data_found then
       l_cd_meaning_new:=null;
       end;

        if g_debug then
          hr_utility.set_location('Entering BAD:'||l_proc||l_cd_meaning_old||' '||l_cd_meaning_new, 108);
        end if;

       ben_cwb_audit_api.create_audit_entry
               (p_group_per_in_ler_id      => l_grp_bdgt_new.group_per_in_ler_id
               ,p_group_pl_id              => l_grp_bdgt_new.group_pl_id
               ,p_lf_evt_ocrd_dt           => l_grp_bdgt_new.lf_evt_ocrd_dt
               ,p_pl_id                    => l_grp_bdgt_new.group_pl_id
               ,p_group_oipl_id            => l_grp_bdgt_new.group_oipl_id
               ,p_audit_type_cd            => 'SU'
               ,p_old_val_varchar          => l_cd_meaning_old
               ,p_new_val_varchar          => l_cd_meaning_new
               ,p_date_stamp               => sysdate
               ,p_change_made_by_person_id => l_person_id
               ,p_cwb_audit_id             => l_cwb_audit_id
               ,p_object_version_number    => l_object_version_number
               );
   end if;
  end if;
  if(  ((p_grp_bdgt_old.approval_cd is null) 
    and (l_grp_bdgt_new.approval_cd is not null))
    or ((l_grp_bdgt_new.approval_cd is null) 
    and (p_grp_bdgt_old.approval_cd is not null))
     or (p_grp_bdgt_old.approval_cd <> l_grp_bdgt_new.approval_cd) ) then
   if(ben_cwb_audit_api.return_lookup_validity('AS')=true) then

       
       begin
        select meaning into l_cd_meaning_old 
        from hr_lookups 
        where lookup_type='BEN_APPR_STAT'
        and lookup_code=p_grp_bdgt_old.approval_cd;
       exception
        when no_data_found then
	l_cd_meaning_old:=null;
       end;

       begin
        select meaning into l_cd_meaning_new 
        from hr_lookups 
        where lookup_type='BEN_APPR_STAT'
        and lookup_code=l_grp_bdgt_new.approval_cd;
       exception
        when no_data_found then
	l_cd_meaning_new:=null;
       end;

        if g_debug then
          hr_utility.set_location('Entering AS:'||l_proc||l_cd_meaning_old||' '||l_cd_meaning_new, 109);
        end if;
       
       ben_cwb_audit_api.create_audit_entry
               (p_group_per_in_ler_id      => l_grp_bdgt_new.group_per_in_ler_id
               ,p_group_pl_id              => l_grp_bdgt_new.group_pl_id
               ,p_lf_evt_ocrd_dt           => l_grp_bdgt_new.lf_evt_ocrd_dt
               ,p_pl_id                    => l_grp_bdgt_new.group_pl_id
               ,p_group_oipl_id            => l_grp_bdgt_new.group_oipl_id
               ,p_audit_type_cd            => 'AS'
               ,p_old_val_varchar          => l_cd_meaning_old
               ,p_new_val_varchar          => l_cd_meaning_new
               ,p_date_stamp               => sysdate
               ,p_change_made_by_person_id => l_person_id
               ,p_cwb_audit_id             => l_cwb_audit_id
               ,p_object_version_number    => l_object_version_number
               );
   end if;
  end if;
  if(  ((p_grp_bdgt_old.approval_date is null) 
    and (l_grp_bdgt_new.approval_date is not null))
    or ((l_grp_bdgt_new.approval_date is null) 
    and (p_grp_bdgt_old.approval_date is not null))
     or (p_grp_bdgt_old.approval_date <> l_grp_bdgt_new.approval_date) ) then
   if(ben_cwb_audit_api.return_lookup_validity('AD')=true) then
        if g_debug then
          hr_utility.set_location('Entering AD:'||l_proc||p_grp_bdgt_old.approval_date||' '||l_grp_bdgt_new.approval_date, 110);
        end if;

       ben_cwb_audit_api.create_audit_entry
                (p_group_per_in_ler_id      => l_grp_bdgt_new.group_per_in_ler_id
                ,p_group_pl_id              => l_grp_bdgt_new.group_pl_id
                ,p_lf_evt_ocrd_dt           => l_grp_bdgt_new.lf_evt_ocrd_dt
                ,p_pl_id                    => l_grp_bdgt_new.group_pl_id
                ,p_group_oipl_id            => l_grp_bdgt_new.group_oipl_id
                ,p_audit_type_cd            => 'AD'
                ,p_old_val_date             => p_grp_bdgt_old.approval_date
                ,p_new_val_date             => l_grp_bdgt_new.approval_date
                ,p_date_stamp               => sysdate
                ,p_change_made_by_person_id => l_person_id
                ,p_cwb_audit_id             => l_cwb_audit_id
                ,p_object_version_number    => l_object_version_number
                );
   end if;
  end if;
  if(  ((p_grp_bdgt_old.rsrv_val is null) 
    and (l_grp_bdgt_new.rsrv_val is not null))
    or ((l_grp_bdgt_new.rsrv_val is null) 
    and (p_grp_bdgt_old.rsrv_val is not null))
     or (p_grp_bdgt_old.rsrv_val <> l_grp_bdgt_new.rsrv_val) ) then
   if(ben_cwb_audit_api.return_lookup_validity('RS')=true) then

        if g_debug then
          hr_utility.set_location('Entering RS:'||l_proc||p_grp_bdgt_old.rsrv_val||' '||l_grp_bdgt_new.rsrv_val, 111);
        end if;

       ben_cwb_audit_api.create_audit_entry
                (p_group_per_in_ler_id      => l_grp_bdgt_new.group_per_in_ler_id
                ,p_group_pl_id              => l_grp_bdgt_new.group_pl_id
                ,p_lf_evt_ocrd_dt           => l_grp_bdgt_new.lf_evt_ocrd_dt
                ,p_pl_id                    => l_grp_bdgt_new.group_pl_id
                ,p_group_oipl_id            => l_grp_bdgt_new.group_oipl_id
                ,p_audit_type_cd            => 'RS'
                ,p_old_val_number           => p_grp_bdgt_old.rsrv_val
                ,p_new_val_number           => l_grp_bdgt_new.rsrv_val
                ,p_date_stamp               => sysdate
                ,p_change_made_by_person_id => l_person_id
                ,p_cwb_audit_id             => l_cwb_audit_id
                ,p_object_version_number    => l_object_version_number
                );
   end if;
  end if;
  if(  ((p_grp_bdgt_old.access_cd is null) 
    and (l_grp_bdgt_new.access_cd is not null))
    or ((l_grp_bdgt_new.access_cd is null) 
    and (p_grp_bdgt_old.access_cd is not null))
     or (p_grp_bdgt_old.access_cd <> l_grp_bdgt_new.access_cd) ) then
   if(ben_cwb_audit_api.return_lookup_validity('AC')=true) then

      begin
        select meaning into l_cd_meaning_old 
        from hr_lookups 
        where lookup_type='BEN_WS_ACC'
        and lookup_code=p_grp_bdgt_old.access_cd;
       exception
        when no_data_found then
	l_cd_meaning_old:= p_grp_bdgt_old.access_cd;
       end;

       begin
        select meaning into l_cd_meaning_new 
        from hr_lookups 
        where lookup_type='BEN_WS_ACC'
        and lookup_code=l_grp_bdgt_new.access_cd;
       exception
        when no_data_found then
	l_cd_meaning_new:= l_grp_bdgt_new.access_cd;
       end;

	if g_debug then
          hr_utility.set_location('Entering AC:'||l_proc||l_cd_meaning_old||' '||l_cd_meaning_new, 112);
        end if;

       
       ben_cwb_audit_api.create_audit_entry
               (p_group_per_in_ler_id      => l_grp_bdgt_new.group_per_in_ler_id
               ,p_group_pl_id              => l_grp_bdgt_new.group_pl_id
               ,p_lf_evt_ocrd_dt           => l_grp_bdgt_new.lf_evt_ocrd_dt
               ,p_pl_id                    => l_grp_bdgt_new.group_pl_id
               ,p_group_oipl_id            => l_grp_bdgt_new.group_oipl_id
               ,p_audit_type_cd            => 'AC'
               ,p_old_val_varchar          => l_cd_meaning_old
               ,p_new_val_varchar          => l_cd_meaning_new
               ,p_date_stamp               => sysdate
               ,p_change_made_by_person_id => l_person_id
               ,p_cwb_audit_id             => l_cwb_audit_id
               ,p_object_version_number    => l_object_version_number
               );
   end if;
  end if;
  if g_debug then
     hr_utility.set_location('Exiting person groups '|| l_proc, 200);
  end if;

end create_audit_record;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_group_budget >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_group_budget
  (p_validate                      in     boolean  default false
  ,p_group_per_in_ler_id           in     number  
  ,p_group_pl_id                   in     number  
  ,p_group_oipl_id                 in     number  
  ,p_lf_evt_ocrd_dt                in     date       default hr_api.g_date
  ,p_bdgt_pop_cd                   in     varchar2   default hr_api.g_varchar2 
  ,p_due_dt                        in     date       default hr_api.g_date  
  ,p_access_cd                     in     varchar2   default hr_api.g_varchar2 
  ,p_approval_cd                   in     varchar2   default hr_api.g_varchar2 
  ,p_approval_date                 in     date       default hr_api.g_date  
  ,p_approval_comments             in     varchar2   default hr_api.g_varchar2 
  ,p_dist_bdgt_val                 in     number     default hr_api.g_number  
  ,p_ws_bdgt_val                   in     number     default hr_api.g_number  
  ,p_rsrv_val                      in     number     default hr_api.g_number  
  ,p_dist_bdgt_mn_val              in     number     default hr_api.g_number  
  ,p_dist_bdgt_mx_val              in     number     default hr_api.g_number  
  ,p_dist_bdgt_incr_val            in     number     default hr_api.g_number  
  ,p_ws_bdgt_mn_val                in     number     default hr_api.g_number  
  ,p_ws_bdgt_mx_val                in     number     default hr_api.g_number  
  ,p_ws_bdgt_incr_val              in     number     default hr_api.g_number  
  ,p_rsrv_mn_val                   in     number     default hr_api.g_number  
  ,p_rsrv_mx_val                   in     number     default hr_api.g_number  
  ,p_rsrv_incr_val                 in     number     default hr_api.g_number  
  ,p_dist_bdgt_iss_val             in     number     default hr_api.g_number  
  ,p_ws_bdgt_iss_val               in     number     default hr_api.g_number  
  ,p_dist_bdgt_iss_date            in     date       default hr_api.g_date  
  ,p_ws_bdgt_iss_date              in     date       default hr_api.g_date  
  ,p_ws_bdgt_val_last_upd_date     in     date       default hr_api.g_date  
  ,p_dist_bdgt_val_last_upd_date   in     date       default hr_api.g_date  
  ,p_rsrv_val_last_upd_date        in     date       default hr_api.g_date  
  ,p_ws_bdgt_val_last_upd_by       in     number     default hr_api.g_number  
  ,p_dist_bdgt_val_last_upd_by     in     number     default hr_api.g_number  
  ,p_rsrv_val_last_upd_by          in     number     default hr_api.g_number  
  ,p_submit_cd                     in     varchar2   default hr_api.g_varchar2 
  ,p_submit_date                   in     date       default hr_api.g_date  
  ,p_submit_comments               in     varchar2   default hr_api.g_varchar2
  ,p_perf_min_max_edit             in     varchar2   default 'Y'
  ,p_object_version_number         in out nocopy     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number    number;
  l_grp_bdgt_old csr_grps%rowtype;
  --
  cursor csr_mn_mx_vals is
  select dist_bdgt_mn_val
        ,dist_bdgt_mx_val
	,dist_bdgt_incr_val
	,ws_bdgt_mn_val
	,ws_bdgt_mx_val
	,ws_bdgt_incr_val
	,rsrv_mn_val
	,rsrv_mx_val
	,rsrv_incr_val
        ,group_per_in_ler_id
  from ben_cwb_person_groups grp
  where group_per_in_ler_id = p_group_per_in_ler_id
  and   group_pl_id = p_group_pl_id
  and   group_oipl_id = p_group_oipl_id;
  --
  l_mn_mx_vals csr_mn_mx_vals%rowtype;
  --
  l_proc                varchar2(72) := g_package||'update_group_budget';
begin
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint update_group_budget;
  --
  -- select the existing values from table.
  open  csr_grps(p_group_per_in_ler_id
                ,p_group_pl_id
                ,p_group_oipl_id);
  fetch csr_grps into l_grp_bdgt_old;
  close csr_grps;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;  
  --
  -- Call Before Process User Hook
  --
  begin
    ben_cwb_person_groups_bk2.update_group_budget_b
      (p_group_per_in_ler_id           =>   p_group_per_in_ler_id         
        ,p_group_pl_id                   =>   p_group_pl_id                 
        ,p_group_oipl_id                 =>   p_group_oipl_id               
        ,p_lf_evt_ocrd_dt                =>   p_lf_evt_ocrd_dt              
        ,p_bdgt_pop_cd                   =>   p_bdgt_pop_cd                 
        ,p_due_dt                        =>   p_due_dt                      
        ,p_access_cd                     =>   p_access_cd                   
        ,p_approval_cd                   =>   p_approval_cd                 
        ,p_approval_date                 =>   p_approval_date               
        ,p_approval_comments             =>   p_approval_comments           
        ,p_dist_bdgt_val                 =>   p_dist_bdgt_val               
        ,p_ws_bdgt_val                   =>   p_ws_bdgt_val                 
        ,p_rsrv_val                      =>   p_rsrv_val                    
        ,p_dist_bdgt_mn_val              =>   p_dist_bdgt_mn_val            
        ,p_dist_bdgt_mx_val              =>   p_dist_bdgt_mx_val            
        ,p_dist_bdgt_incr_val            =>   p_dist_bdgt_incr_val          
        ,p_ws_bdgt_mn_val                =>   p_ws_bdgt_mn_val              
        ,p_ws_bdgt_mx_val                =>   p_ws_bdgt_mx_val              
        ,p_ws_bdgt_incr_val              =>   p_ws_bdgt_incr_val            
        ,p_rsrv_mn_val                   =>   p_rsrv_mn_val                 
        ,p_rsrv_mx_val                   =>   p_rsrv_mx_val                 
        ,p_rsrv_incr_val                 =>   p_rsrv_incr_val               
        ,p_dist_bdgt_iss_val             =>   p_dist_bdgt_iss_val           
        ,p_ws_bdgt_iss_val               =>   p_ws_bdgt_iss_val             
        ,p_dist_bdgt_iss_date            =>   p_dist_bdgt_iss_date          
        ,p_ws_bdgt_iss_date              =>   p_ws_bdgt_iss_date            
        ,p_ws_bdgt_val_last_upd_date     =>   p_ws_bdgt_val_last_upd_date   
        ,p_dist_bdgt_val_last_upd_date   =>   p_dist_bdgt_val_last_upd_date 
        ,p_rsrv_val_last_upd_date        =>   p_rsrv_val_last_upd_date      
        ,p_ws_bdgt_val_last_upd_by       =>   p_ws_bdgt_val_last_upd_by     
        ,p_dist_bdgt_val_last_upd_by     =>   p_dist_bdgt_val_last_upd_by   
        ,p_rsrv_val_last_upd_by          =>   p_rsrv_val_last_upd_by        
        ,p_submit_cd                     =>   p_submit_cd                   
        ,p_submit_date                   =>   p_submit_date                 
        ,p_submit_comments               =>   p_submit_comments 
        ,p_object_version_number         =>   l_object_version_number 
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_group_budget'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  -- 

  -- Min Max Edits
  --
  if p_perf_min_max_edit = 'Y' then
    --
    open csr_mn_mx_vals;
    fetch csr_mn_mx_vals into l_mn_mx_vals;
    close csr_mn_mx_vals;
    --
    if (p_dist_bdgt_mx_val is null or
        p_dist_bdgt_mx_val <> hr_api.g_number) then
       l_mn_mx_vals.dist_bdgt_mx_val := p_dist_bdgt_mx_val;
    end if;
    --
    if (p_dist_bdgt_mn_val is null or
        p_dist_bdgt_mn_val <> hr_api.g_number) then
      l_mn_mx_vals.dist_bdgt_mn_val := p_dist_bdgt_mn_val;
    end if;
    --
    if (p_dist_bdgt_incr_val is null or
        p_dist_bdgt_incr_val <> hr_api.g_number) then
      l_mn_mx_vals.dist_bdgt_incr_val := p_dist_bdgt_incr_val;
    end if;
    --
    --
    if g_debug then
      hr_utility.set_location(l_proc, 30);
    end if;
    --
    if (p_ws_bdgt_mx_val is null or
        p_ws_bdgt_mx_val <> hr_api.g_number) then
       l_mn_mx_vals.ws_bdgt_mx_val := p_ws_bdgt_mx_val;
    end if;
    --
    if (p_ws_bdgt_mn_val is null or
        p_ws_bdgt_mn_val <> hr_api.g_number) then
      l_mn_mx_vals.ws_bdgt_mn_val := p_ws_bdgt_mn_val;
    end if;
    --
    if (p_ws_bdgt_incr_val is null or
        p_ws_bdgt_incr_val <> hr_api.g_number) then
      l_mn_mx_vals.ws_bdgt_incr_val := p_ws_bdgt_incr_val;
    end if;
    --
    if g_debug then
      hr_utility.set_location(l_proc, 50);
    end if;
    --
    -- Check Min, Max and Inc for Dist Bdgt Val
    --
    check_min_max(p_val     => p_dist_bdgt_val
                 ,p_iss_val => p_dist_bdgt_iss_val
                 ,p_min_val => l_mn_mx_vals.dist_bdgt_mn_val
	         ,p_max_val => l_mn_mx_vals.dist_bdgt_mx_val
	         ,p_incr_val => l_mn_mx_vals.dist_bdgt_incr_val
	         ,p_group_per_in_ler_id => p_group_per_in_ler_id);
    --
    if g_debug then
      hr_utility.set_location(l_proc, 60);
    end if;
    --
    --
    -- Check Min, Max and Inc for Ws Bdgt Val
    --
    check_min_max(p_val     => p_ws_bdgt_val
                 ,p_iss_val => p_ws_bdgt_iss_val
                 ,p_min_val => l_mn_mx_vals.ws_bdgt_mn_val
                 ,p_max_val => l_mn_mx_vals.ws_bdgt_mx_val
	         ,p_incr_val => l_mn_mx_vals.ws_bdgt_incr_val
                 ,p_group_per_in_ler_id => p_group_per_in_ler_id); 
     --
     if g_debug then
       hr_utility.set_location(l_proc, 70);
     end if;
     --
  end if; -- of p_perf_min_max_edit
  --
  if p_rsrv_val is not null and 
     p_rsrv_val <> hr_api.g_number and
     p_rsrv_val <> nvl(l_grp_bdgt_old.rsrv_val, hr_api.g_number) then
    --
    if l_mn_mx_vals.group_per_in_ler_id is null then
      open csr_mn_mx_vals;
      fetch csr_mn_mx_vals into l_mn_mx_vals;
      close csr_mn_mx_vals;
    end if;
    --
    if (p_rsrv_mx_val is null or
        p_rsrv_mx_val <> hr_api.g_number) then
       l_mn_mx_vals.rsrv_mx_val := p_rsrv_mx_val;
    end if;
    --
    if (p_rsrv_mn_val is null or
        p_rsrv_mn_val <> hr_api.g_number) then
      l_mn_mx_vals.rsrv_mn_val := p_rsrv_mn_val;
    end if;
    --
    if (p_rsrv_incr_val is null or
        p_rsrv_incr_val <> hr_api.g_number) then
      l_mn_mx_vals.rsrv_incr_val := p_rsrv_incr_val;
    end if;
    --
    -- Check Min, Max and Inc for Rsrv Val
    --
    check_min_max(p_val     => p_rsrv_val
                 ,p_iss_val => null
                 ,p_min_val => l_mn_mx_vals.rsrv_mn_val
                 ,p_max_val => l_mn_mx_vals.rsrv_mx_val
                 ,p_incr_val => l_mn_mx_vals.rsrv_incr_val
                 ,p_group_per_in_ler_id => p_group_per_in_ler_id);
    --
  end if;
  --
  -- Process Logic
  --
  ben_cpg_upd.upd
           (p_group_per_in_ler_id           =>   p_group_per_in_ler_id         
           ,p_group_pl_id                   =>   p_group_pl_id                 
           ,p_group_oipl_id                 =>   p_group_oipl_id               
           ,p_lf_evt_ocrd_dt                =>   p_lf_evt_ocrd_dt              
           ,p_bdgt_pop_cd                   =>   p_bdgt_pop_cd                 
           ,p_due_dt                        =>   p_due_dt                      
           ,p_access_cd                     =>   p_access_cd                   
           ,p_approval_cd                   =>   p_approval_cd                 
           ,p_approval_date                 =>   p_approval_date               
           ,p_approval_comments             =>   p_approval_comments           
           ,p_dist_bdgt_val                 =>   p_dist_bdgt_val               
           ,p_ws_bdgt_val                   =>   p_ws_bdgt_val                 
           ,p_rsrv_val                      =>   p_rsrv_val                    
           ,p_dist_bdgt_mn_val              =>   p_dist_bdgt_mn_val            
           ,p_dist_bdgt_mx_val              =>   p_dist_bdgt_mx_val            
           ,p_dist_bdgt_incr_val            =>   p_dist_bdgt_incr_val          
           ,p_ws_bdgt_mn_val                =>   p_ws_bdgt_mn_val              
           ,p_ws_bdgt_mx_val                =>   p_ws_bdgt_mx_val              
           ,p_ws_bdgt_incr_val              =>   p_ws_bdgt_incr_val            
           ,p_rsrv_mn_val                   =>   p_rsrv_mn_val                 
           ,p_rsrv_mx_val                   =>   p_rsrv_mx_val                 
           ,p_rsrv_incr_val                 =>   p_rsrv_incr_val               
           ,p_dist_bdgt_iss_val             =>   p_dist_bdgt_iss_val           
           ,p_ws_bdgt_iss_val               =>   p_ws_bdgt_iss_val             
           ,p_dist_bdgt_iss_date            =>   p_dist_bdgt_iss_date          
           ,p_ws_bdgt_iss_date              =>   p_ws_bdgt_iss_date            
           ,p_ws_bdgt_val_last_upd_date     =>   p_ws_bdgt_val_last_upd_date   
           ,p_dist_bdgt_val_last_upd_date   =>   p_dist_bdgt_val_last_upd_date 
           ,p_rsrv_val_last_upd_date        =>   p_rsrv_val_last_upd_date      
           ,p_ws_bdgt_val_last_upd_by       =>   p_ws_bdgt_val_last_upd_by     
           ,p_dist_bdgt_val_last_upd_by     =>   p_dist_bdgt_val_last_upd_by   
           ,p_rsrv_val_last_upd_by          =>   p_rsrv_val_last_upd_by        
           ,p_submit_cd                     =>   p_submit_cd                   
           ,p_submit_date                   =>   p_submit_date                 
           ,p_submit_comments               =>   p_submit_comments
           ,p_object_version_number         =>   l_object_version_number
         );
  --
  -- Call After Process User Hook
  --
  begin
    ben_cwb_person_groups_bk2.update_group_budget_a
      (p_group_per_in_ler_id           =>   p_group_per_in_ler_id         
        ,p_group_pl_id                   =>   p_group_pl_id                 
        ,p_group_oipl_id                 =>   p_group_oipl_id               
        ,p_lf_evt_ocrd_dt                =>   p_lf_evt_ocrd_dt              
        ,p_bdgt_pop_cd                   =>   p_bdgt_pop_cd                 
        ,p_due_dt                        =>   p_due_dt                      
        ,p_access_cd                     =>   p_access_cd                   
        ,p_approval_cd                   =>   p_approval_cd                 
        ,p_approval_date                 =>   p_approval_date               
        ,p_approval_comments             =>   p_approval_comments           
        ,p_dist_bdgt_val                 =>   p_dist_bdgt_val               
        ,p_ws_bdgt_val                   =>   p_ws_bdgt_val                 
        ,p_rsrv_val                      =>   p_rsrv_val                    
        ,p_dist_bdgt_mn_val              =>   p_dist_bdgt_mn_val            
        ,p_dist_bdgt_mx_val              =>   p_dist_bdgt_mx_val            
        ,p_dist_bdgt_incr_val            =>   p_dist_bdgt_incr_val          
        ,p_ws_bdgt_mn_val                =>   p_ws_bdgt_mn_val              
        ,p_ws_bdgt_mx_val                =>   p_ws_bdgt_mx_val              
        ,p_ws_bdgt_incr_val              =>   p_ws_bdgt_incr_val            
        ,p_rsrv_mn_val                   =>   p_rsrv_mn_val                 
        ,p_rsrv_mx_val                   =>   p_rsrv_mx_val                 
        ,p_rsrv_incr_val                 =>   p_rsrv_incr_val               
        ,p_dist_bdgt_iss_val             =>   p_dist_bdgt_iss_val           
        ,p_ws_bdgt_iss_val               =>   p_ws_bdgt_iss_val             
        ,p_dist_bdgt_iss_date            =>   p_dist_bdgt_iss_date          
        ,p_ws_bdgt_iss_date              =>   p_ws_bdgt_iss_date            
        ,p_ws_bdgt_val_last_upd_date     =>   p_ws_bdgt_val_last_upd_date   
        ,p_dist_bdgt_val_last_upd_date   =>   p_dist_bdgt_val_last_upd_date 
        ,p_rsrv_val_last_upd_date        =>   p_rsrv_val_last_upd_date      
        ,p_ws_bdgt_val_last_upd_by       =>   p_ws_bdgt_val_last_upd_by     
        ,p_dist_bdgt_val_last_upd_by     =>   p_dist_bdgt_val_last_upd_by   
        ,p_rsrv_val_last_upd_by          =>   p_rsrv_val_last_upd_by        
        ,p_submit_cd                     =>   p_submit_cd                   
        ,p_submit_date                   =>   p_submit_date                 
        ,p_submit_comments               =>   p_submit_comments 
        ,p_object_version_number         =>   l_object_version_number 
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_group_budget'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Update is successful. So call the budget summary update.
  update_group_budget_summary
   (p_grp_bdgt_old => l_grp_bdgt_old
   ,p_dist_bdgt_val => p_dist_bdgt_val
   ,p_dist_bdgt_iss_val => p_dist_bdgt_iss_val
   ,p_ws_bdgt_val => p_ws_bdgt_val
   ,p_ws_bdgt_iss_val => p_ws_bdgt_iss_val); 
  --
  --calling the audit log function to write in the audit log
  create_audit_record(l_grp_bdgt_old);
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number  := l_object_version_number;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 80);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_group_budget;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_group_budget;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 99);
    end if;
    raise;
end update_group_budget;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_group_budget >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_group_budget
  (p_validate                      in     boolean  default false
  ,p_group_per_in_ler_id           in     number  
  ,p_group_pl_id                   in     number  
  ,p_group_oipl_id                 in     number 
  ,p_object_version_number         in out nocopy   number
  ,p_update_summary                in     boolean default false
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number number;
  l_proc                varchar2(72) := g_package||'delete_group_budget';
  l_grp_bdgt_old csr_grps%rowtype;
begin
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint delete_group_budget;
  --
  open  csr_grps(p_group_per_in_ler_id
                ,p_group_pl_id
                ,p_group_oipl_id);
  fetch csr_grps into l_grp_bdgt_old;
  close csr_grps;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    BEN_CWB_PERSON_GROUPS_BK3.delete_group_budget_b
      (p_group_per_in_ler_id           =>     p_group_per_in_ler_id  
      ,p_group_pl_id                   =>     p_group_pl_id  
      ,p_group_oipl_id                 =>     p_group_oipl_id
      ,p_object_version_number         =>     l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_group_budget'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  -- 
  
  --
  -- Process Logic
  --
  ben_cpg_del.del
      (p_group_per_in_ler_id                  =>     p_group_per_in_ler_id
      ,p_group_pl_id                          =>     p_group_pl_id
      ,p_group_oipl_id                        =>     p_group_oipl_id
      ,p_object_version_number                =>     l_object_version_number
      );
  --
  -- Call After Process User Hook
  --
  begin
    ben_cwb_person_groups_bk3.delete_group_budget_a
      (p_group_per_in_ler_id           =>     p_group_per_in_ler_id  
      ,p_group_pl_id                   =>     p_group_pl_id  
      ,p_group_oipl_id                 =>     p_group_oipl_id
      ,p_object_version_number         =>     l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_group_budget'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Delete is successful. So call the budget summary update.
  --
  if p_update_summary then
    update_group_budget_summary
     (p_grp_bdgt_old => l_grp_bdgt_old
     ,p_dist_bdgt_val => null
     ,p_dist_bdgt_iss_val => null
     ,p_ws_bdgt_val => null
     ,p_ws_bdgt_iss_val => null);
  end if;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_group_budget;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_group_budget;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    raise;
end delete_group_budget;
--
--
end ben_cwb_person_groups_api;
/
commit;
exit;

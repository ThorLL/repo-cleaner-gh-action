repo=$1
message=$2
actor=$3
declare -l wipe_deployments="$4"
declare -l wipe_workflows="$5"
currentWorkflow=$6

git config --global user.email "$actor@users.noreply.github.com"
git config --global user.name "$actor"

IFS='/' read -ra repo_split <<< "$1"

git clone "https://${repo_split[0]}:$GH_TOKEN@github.com/$repo.git"
cd ${repo_split[1]}

defaultBranch=$(git --no-pager branch --show-current)

branches=$(gh api "repos/$repo/branches" --jq '.[].name')
for branch in $branches; do
    if [ "$branch" != "$defaultBranch" ]; then
			echo "Deleting branch: $branch"
    	gh api --method DELETE "repos/$repo/git/refs/heads/$branch" > /dev/null
    fi
done

releases=$(gh api "repos/$repo/releases" --jq '.[].id')
for release in $releases; do
	echo "Deleting release ID: $release"
	gh api --method DELETE "/repos/$repo/releases/$release" > /dev/null
done

tags=$(gh api "repos/$repo/tags" --jq '.[].name')
for tag in $tags; do
	echo "Deleting tag: $tag"
	gh api --method DELETE "repos/$repo/git/refs/tags/$tag" > /dev/null
done

git checkout --orphan temp
git add -A
git commit -am "$message"
git branch -D $defaultBranch
git branch -m main
git push -f origin $defaultBranch
git gc --aggressive --prune=all


if [ "$wipe_deployments" == "true" ]; then
	deployments=$(gh api "/repos/$repo/deployments" --jq '.[].id')
	for deployment in $deployments; do
		echo "Deleting deployment ID: $deployment"
		gh api --method DELETE "repos/$repo/deployments/$deployment" > /dev/null
	done
elif [ "$wipe_deployments" != "false" ]; then
		echo "wipe-deployments must be 'false' or 'true'"
		echo "Execution continues, but no deployments will be deleted"
fi

if [ "$wipe_workflows" == "true" ]; then
	workflows=$(gh api "/repos/$repo/actions/runs" --jq '.workflow_runs.[].id')
	for workflow in $workflows; do
		if [ "$workflow" != "$currentWorkflow" ]; then
			echo "Deleting workflow ID: $workflow"
			gh api --method DELETE "repos/$repo/actions/runs/$workflow" > /dev/null
		fi
	done
elif [ "$wipe_workflows" != "false" ]; then
		echo "wipe-workflow-history must be 'false' or 'true'"
			echo "Execution continues, but the workflow history will remain"
fi


